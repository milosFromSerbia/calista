/*

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at 
  
           http://www.mozilla.org/MPL/ 
  
  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License. 
  
  The Original Code is CalistA Framework.
  
  The Initial Developer of the Original Code is
  ALCARAZ Marc (aka eKameleon)  <ekameleon@gmail.com>.
  Portions created by the Initial Developer are Copyright (C) 2004-2010
  the Initial Developer. All Rights Reserved.
  
  Contributor(s) :
  
  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the LGPL or the GPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.
  
*/
package libraries.gzip 
{
    import calista.hash.CRC32;

    import flash.errors.IllegalOperationError;
    import flash.system.Capabilities;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    
    /**
     * This encoder encode or decode GZip compressed datas.
     * <p>There are methods for compressing data to GZIP format data (in a ByteArray) 
     * or also for uncompressing a ByteArray containing GZIP data and accessing it in memory as a ByteArray.</p>
     */
    public class GZipBytesEncoder 
    {
        /**
         * Writes bytes of data as GZIP compressed data in a byte array.
         * <p>This particular method takes a "least effort" approach, meaning any optional metadata fields are not included in the GZip data.</p>
         * @param source   The source data to compress and embed in the GZip bytes. The source is a ByteArray instance whose contents are compressed and output to the result byte array.
         * @param modificationDate The file modification date to encode into the GZip format data.
         * @throws ArgumentError If the source argument is null.
         */
        public function compressToByteArray( source:ByteArray , modificationDate:Date = null ):ByteArray
        {
            if (source == null)
            {
                throw new ArgumentError("GZipBytesEncoder.compressToByteArray method failed, the 'source' argument can't be null.") ;
            }
            var position:uint       = source.position ;
            var outStream:ByteArray = new ByteArray();
            var srcBytes:ByteArray  = new ByteArray();
            
            srcBytes.writeBytes(source);
            
            // For details of gzip format, see IETF RFC 1952:
            // http://www.ietf.org/rfc/rfc1952
            
            // gzip is little-endian
            outStream.endian = Endian.LITTLE_ENDIAN;
            
            // 1 byte ID1 -- should be 31/0x1f
            var id1:uint = 31;
            outStream.writeByte(id1);
            
            // 1 byte ID2 -- should be 139/0x8b
            var id2:uint = 139;
            outStream.writeByte(id2);
            
            // 1 byte CM -- should be 8 for DEFLATE
            var cm:uint = 8;
            outStream.writeByte(cm);
            
            // 1 byte FLaGs
            var flags:int = parseInt("00000000", 2);
            outStream.writeByte(flags);
            
            // 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
            var mtime:uint = (modificationDate == null) ? 0 : modificationDate.time ;
            outStream.writeUnsignedInt(mtime);
            
            // 1 byte XFL (flags used by specific compression methods)
            var xfl:uint = parseInt("00000100", 2);
            outStream.writeByte(xfl);
            
            // 1 byte OS
            var os:uint;
            if ( Capabilities.os.indexOf("Windows") >= 0)
            {
                os = 11 ; // NTFS -- WinXP, Win2000, WinNT
            }
            else if ( Capabilities.os.indexOf("Mac OS") >= 0 )
            {
                os = 7 ; // Macintosh
            }
            else // Linux is the only other OS supported by Adobe AIR
            {
                os = 3 ; // Unix
            }
            outStream.writeByte(os) ;
            
            // calculate crc32 and filesize before compressing data
            var crc32:uint = CRC32.checkSum(srcBytes);
            
            var isize:uint = srcBytes.length % Math.pow(2, 32);
            
            // Actual compressed data (up to end - 8 bytes)
            srcBytes.deflate();
            outStream.writeBytes(srcBytes, 0, srcBytes.length);
           
            // 4 bytes CRC32
            outStream.writeUnsignedInt(crc32);
            
            // 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
            outStream.writeUnsignedInt(isize);
            
            source.position = position ;
            
            return outStream;
        }
        
        /**
         * Uncompresses a GZIP-compressed-format ByteArray to a ByteArray object.
         * @param source The ByteArray object to uncompress. The ByteArray's contents are uncompressed and output as the result. In either case the <code>src</code> object must be compressed using the GZip file format.
         * @returns A ByteArray containing the uncompressed bytes that were compressed and encoded in the source file or ByteArray.
         * @throws ArgumentError If the <code>source</code> argument is null.
         * @throws IllegalOperationError If the specified ByteArray is not GZip-format file or data.
         */
        public function uncompressToByteArray( source:ByteArray ):ByteArray
        {
            var gzipData:GZipFile;
            gzipData = parseGZIPData(source);
            var data:ByteArray = gzipData.data ;
            try
            {
                data.inflate();
            }
            catch ( error:Error )
            {
                throw new IllegalOperationError( "The specified source is not a GZip file format file or data." ) ;
            }
            return data;
        }
        
        /**
         * Parses a GZip format ByteArray into an object with properties representing the important characteristics 
         * of the GZIP data (the header and footer metadata, as well as the actual compressed data).
         * <p>For details of gzip format, see IETF RFC 1952 : http://www.ietf.org/rfc/rfc1952</p>
         * @param source The byteArray source of the compressed GZip data to parse.
         * @param name The name of the GZIP file.
         *
         * @returns An GZipFile object containing the information from the source GZIP data.
         * @throws ArgumentError        If the <code>srcBytes</code> argument is null
         *
         * @throws IllegalOperationError If the specified data is not in GZIP-format.
         */
        public function parseGZIPData( source:ByteArray , name:String = "" ):GZipFile
        {
            if (source == null)
            {
                throw new ArgumentError("GZipBytesEncoder.parseGZIPData failed, the source ByteArray can't be null.");
            }
            
            // gzip is little-endian
            source.endian = Endian.LITTLE_ENDIAN;
            
            // 1 byte ID1 -- should be 31/0x1f or else throw an error
            var id1:uint = source.readUnsignedByte();
            if (id1 != 0x1f)
            {
                throw new IllegalOperationError("GZipBytesEncoder.parseGZIPData failed, the specified data is not in GZIP file format structure.");
            }
           
            // 1 byte ID2 -- should be 139/0x8b or else throw an error
            var id2:uint = source.readUnsignedByte();
            if (id2 != 0x8b)
            {
                    throw new IllegalOperationError("GZipBytesEncoder.parseGZIPData failed, the specified data is not in GZIP file format structure.");
            }
            
            // 1 byte CM -- should be 8 for DEFLATE or else throw an error
            var cm:uint = source.readUnsignedByte();
            if (cm != 8)
            {
                throw new IllegalOperationError("GZipBytesEncoder.parseGZIPData failed, the specified data is not in GZIP file format structure.");
            }
            
            // 1 byte FLaGs
            var flags:int = source.readByte();
            
            // ftext: the file is probably ASCII text
            var hasFtext:Boolean = ((flags >> 7) & 1) == 1 ;
            
            // fhcrc: a CRC16 for the gzip header is present
            var hasFhcrc:Boolean = ((flags >> 6) & 1) == 1 ;
            
            // fextra: option extra fields are present
            var hasFextra:Boolean = ((flags >> 5) & 1) == 1 ;
            
            // fname: an original file name is present, terminated by a zero byte
            var hasFname:Boolean = ((flags >> 4) & 1) == 1 ;
            
            // fcomment: a zero-terminated file comment (intended for human consumption) is present
            var hasFcomment:Boolean = ((flags >> 3) & 1) == 1 ;
            
            // must throw an error if any of the remaining bits are non-zero
            
            var flagsError:Boolean ;
            
            flagsError = ((flags >> 2) & 1 == 1) ? true : flagsError;
            flagsError = ((flags >> 1) & 1 == 1) ? true : flagsError;
            flagsError = (flags & 1 == 1) ? true : flagsError;
            
            if (flagsError)
            {
                throw new IllegalOperationError("GZipBytesEncoder.parseGZIPData failed, the specified data is not in GZip file format structure.") ;
            }
            
            // 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
            var mtime:uint = source.readUnsignedInt();
            
            // 1 byte XFL (flags used by specific compression methods)
            var xfl:uint = source.readUnsignedByte();
            
            // 1 byte OS
            var os:uint = source.readUnsignedByte();
            
            // (if FLG.EXTRA is set) 2 bytes XLEN, XLEN bytes of extra field
            if (hasFextra)
            {
                var extra:String = source.readUTF() ;
            }
            
            // (if FLG.FNAME is set) original filename, terminated by 0
            var filename:String ;
            if (hasFname)
            {
                var fnameBytes:ByteArray = new ByteArray();
                while (source.readUnsignedByte() != 0)
                {
                    // move position back by 1 to make up for the readUnsignedByte() in the conditional
                    source.position -= 1;
                    fnameBytes.writeByte(source.readByte());
                }
                fnameBytes.position = 0;
                filename = fnameBytes.readUTFBytes(fnameBytes.length);
            }
            
            // (if FLG.FCOMMENT is set) file comment, zero terminated
            var fcomment:String ;
            if  (hasFcomment )
            {
                var fcommentBytes:ByteArray = new ByteArray();
                while (source.readUnsignedByte() != 0)
                {
                    // move position back by 1 to make up for the readUnsignedByte() in the conditional
                    source.position -= 1;
                    fcommentBytes.writeByte(source.readByte()) ;
                }
                fcommentBytes.position = 0 ;
                fcomment = fcommentBytes.readUTFBytes(fcommentBytes.length) ;
            }
            
            // (if FLG.FHCRC is set) 2 bytes CRC16
            if (hasFhcrc)
            {
                var fhcrc:int = source.readUnsignedShort() ;
            }
            
            // Actual compressed data (up to end - 8 bytes)
            var dataSize:int = (source.length - source.position) - 8 ;
            var data:ByteArray = new ByteArray() ;
            
            source.readBytes(data, 0, dataSize) ;
           
            // 4 bytes CRC32
            var crc32:uint = source.readUnsignedInt() ;
           
            // 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
            var isize:uint = source.readUnsignedInt() ;
           
            return new GZipFile(data, isize, new Date(mtime), name, filename, fcomment);
        }
    }
}
