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

package libraries.zip 
{
    import calista.hash.Adler32;
    import calista.hash.CRC32;
    
    import system.Version;
    import system.hack;
    
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.Endian;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.describeType;

    /**
     * This class is used to read entries from a zip file. 
     */
    public class ZipFile 
    {
        use namespace hack ;
        
        /**
         * Creates a new ZipFile instance;
         * @param encoding The encoding type of the name of the file (default utf-8).
         */
        public function ZipFile( charSet:String = "utf-8" ) 
        {
            _data         = new ByteArray()   ;
            _data.endian  = Endian.BIG_ENDIAN ;
            _extraFields  = new Dictionary()  ;
            _charSet      = charSet           ;
        }
        
        /**
         * Indicates the compression method value of the zip file.
         */
        public function get compressionMethod():int 
        {
            return _compressionMethod;
        }
        
        /**
         * Determinates the ByteArray content of the zip file.
         */
        public function get content():ByteArray 
        {
            return _data ;
        }
        
        /**
         * @private
         */
        public function set content( data:ByteArray ):void 
        {
            if( data != null && data.length > 0 ) 
            {
                data.position = 0;
                data.readBytes( _data , 0 , data.length ) ;
                _crc32 = CRC32.checkSum( _data ) ;
                _hasAdler32 = false;
            }
            else 
            {
                _data.length   = 0 ;
                _data.position = 0 ;
                isCompressed   = false ;
            }
            compress();
        }
        
        /**
         * Indicates the cyclic redundancy check (CRC) value of the zip file. 
         */
        public function get crc32():uint 
        {
            return uint(_crc32) ;
        }
        
        /**
         * Determinates the Date representation of the zip file.
         */
        public function get date():Date 
        {
            return _date ;
        }
        
        /**
         * @private
         */
        public function set date( date:Date ):void 
        {
            this._date = date || new Date() ;
        }
        
        /**
         * Determinates the file name of the zip file (including relative path).
         */
        public function get name():String 
        {
            return _name;
        }
        
        /**
         * @private
         */
        public function set name( value:String ):void 
        {
            _name = value;
        }
        
        /**
         * Indicates the size of the compressed file (in bytes).
         */
        public function get sizeCompressed():uint 
        {
            return _sizeCompressed;
        }
        
        /**
         * Indicates the size of the uncompressed file (in bytes).
         */
        public function get sizeUncompressed():uint 
        {
            return _sizeUncompressed;
        }
        
        /**
         * Indicates the version of the zip file.
         */
        public function get version():Version 
        {
            return _version;
        }
        
        /**
         * Returns the files content as string.
         * @param recompress If <code>true</code>, the raw file content is recompressed after decoding the string.
         * @param charset The character set used for decoding (default "utf-8").
         * @return The file as string.
         */
        public function getContentAsString( recompress:Boolean = true, charset:String = "utf-8" ):String 
        {
            if( isCompressed ) 
            {
                uncompress();
            }
            _data.position = 0 ;
            var str:String;
            // Is readMultiByte completely trustworthy with utf-8? For now, readUTFBytes will take over.
            if( charset == "utf-8" ) 
            {
                str = _data.readUTFBytes(_data.bytesAvailable) ;
            }
            else 
            {
                str = _data.readMultiByte(_data.bytesAvailable, charset) ;
            }
            _data.position = 0;
            if(recompress) 
            {
                compress() ;
            }
            return str;
        }
        
        /**
         * Serializes this zip archive into an IDataOutput stream (such as ByteArray or FileStream) according to PKZIP APPNOTE.TXT
         * @param stream The stream to serialize the zip archive into.
         * @param includeAdler32 If set to true, include Adler32 checksum.
         * @param centralDir If set to true, serialize a central directory entry
         * @param centralDirOffset Relative offset of local header (for central directory only).
         * 
         * @return The serialized zip file.
         */
        public function serialize( stream:IDataOutput, includeAdler32:Boolean = false, centralDir:Boolean = false, centralDirOffset:uint = 0):uint 
        {
            if(stream == null) { return 0; }
            if(centralDir) 
            {
                /////////// Write central directory file header signature
                
                stream.writeUnsignedInt(0x02014b50) ; 
                
                /////////// Write "version made by" host (usually 0) and number (always 2.0)
                
                stream.writeShort((_version.valueOf() << 8) | 0x14); 
            } 
            else 
            {
                stream.writeUnsignedInt( 0x04034b50 ) ; // Write local file header signature
            }
            
            /////////// Write "version needed to extract" host (usually 0) and number (always 2.0)
            
            stream.writeShort((_version.valueOf() << 8) | 0x14) ;
            
            /////////// Write the general purpose flag
            // - no encryption
            // - normal deflate
            // - no data descriptors
            // - no compressed patched data
            // - unicode as specified in _encoding 
            
            stream.writeShort((_charSet == "utf-8") ? 0x0800 : 0);
            
            /////////// Write compression method (always deflate)
            
            stream.writeShort( ZipCompression.DEFLATED ) ;
            
            /////////// Write date
            
            var d:Date         = date || new Date() ;
            var msdosTime:uint = uint(d.getSeconds()) | (uint(d.getMinutes()) << 5) | (uint(d.getHours()) << 11);
            var msdosDate:uint = uint(d.getDate()) | (uint(d.getMonth() + 1) << 5) | (uint(d.getFullYear() - 1980) << 9);
            
            // FIXME use external tool class to convert dos time/date in timestamp
            
            stream.writeShort(msdosTime);
            stream.writeShort(msdosDate);
            
            // Write CRC32
            
            stream.writeUnsignedInt( uint(_crc32) ) ;
            
            // Write compressed size
            stream.writeUnsignedInt(_sizeCompressed);
            
            // Write uncompressed size
            
            stream.writeUnsignedInt(_sizeUncompressed);
            
            // Prep name
            
            var ba:ByteArray = new ByteArray() ;
            ba.endian = Endian.LITTLE_ENDIAN ;
            
            if (_charSet == "utf-8") 
            {
                ba.writeUTFBytes(_name);
            }
            else 
            {
                ba.writeMultiByte(_name, _charSet) ;
            }
            
            var nameSize:uint = ba.position ;
            
            // Prep extra fields
            
            for( var headerId:Object in _extraFields ) 
            {
                var extraBytes:ByteArray = _extraFields[headerId] as ByteArray ;
                if(extraBytes != null) 
                {
                    ba.writeShort(uint(headerId)) ;
                    ba.writeShort(uint(extraBytes.length)) ;
                    ba.writeBytes(extraBytes) ;
                }
            }
            
            if (includeAdler32) 
            {
                if (!_hasAdler32) 
                {
                    var compressed:Boolean = isCompressed;
                    if (compressed) 
                    {
                        uncompress() ; 
                    }
                    _adler32 = Adler32.checkSum(_data, 0, _data.length) ;
                    _hasAdler32 = true ;
                    if (compressed) 
                    { 
                        compress() ; 
                    }
                }
                ba.writeShort(0xdada) ;
                ba.writeShort(4) ;
                ba.writeUnsignedInt( uint(_adler32) ) ;
            }
            
            var extrafieldsSize:uint = ba.position - nameSize ;
            
            // Prep comment (currently unused)
            if( centralDir && _comment.length > 0 )  
            {
                if (_charSet == "utf-8") 
                {
                    ba.writeUTFBytes(_comment);
                }
                else 
                {
                    ba.writeMultiByte(_comment, _charSet) ;
                }
            }
            var commentSize:uint = ba.position - nameSize - extrafieldsSize ;
            
            // Write name and extra field sizes
            
            stream.writeShort(nameSize);
            stream.writeShort(extrafieldsSize);
            
            if(centralDir) 
            {
                // Write comment size
                
                stream.writeShort(commentSize) ;
                
                // Write disk number start (always 0)
                
                stream.writeShort(0) ;
                
                // Write file attributes (always 0)
                
                stream.writeShort(0) ;
                stream.writeUnsignedInt(0) ;
                
                // Write relative offset of local header
                
                stream.writeUnsignedInt(centralDirOffset) ;
            }
            // Write name, extra field and comment
            
            if(nameSize + extrafieldsSize + commentSize > 0) 
            {
                stream.writeBytes( ba ) ;
            }
            // Write file
            
            var fileSize:uint = 0;
            if( !centralDir && _sizeCompressed > 0 ) 
            {
                if( HAS_INFLATE ) 
                {
                    fileSize = _data.length;
                    stream.writeBytes(_data, 0, fileSize) ;
                }
                else 
                {
                    fileSize = _data.length - 6;
                    stream.writeBytes(_data, 2, fileSize) ;
                }
            }
            var size:uint = ZipTag.LOCHDR + nameSize + extrafieldsSize + commentSize + fileSize ;
            if( centralDir ) 
            {
                size += ZipTag.EXTHDR ;
            }
            return size ;
        } 
        
        /**
         * Sets a string as the file's content.
         * @param value The string.
         * @param charset The character set used for decoding (default "utf-8").
         */
        public function setContentAsString( value:String, charset:String = "utf-8" ):void 
        {
            _data.length   = 0 ;
            _data.position = 0 ;
            isCompressed   = false ;
            if( value != null && value.length > 0 ) 
            {
                if(charset == "utf-8") 
                {
                    _data.writeUTFBytes(value);
                } 
                else 
                {
                    _data.writeMultiByte(value, charset);
                }
                _crc32 = CRC32.checkSum( _data ) ;
                _hasAdler32 = false ;
            }
            compress();
        }
        
        /**
         * Returns the String representation of the object.
         * @return the String representation of the object.
         */
        public function toString():String 
        {
            return "[FZipFile"
                 + " name:" + _name
                 + " date:" + _date
                 + " sizeCompressed:" + _sizeCompressed
                 + " sizeUncompressed:" + _sizeUncompressed
                 + " version:" + _version
                 + " compressionMethod:" + _compressionMethod
                 + " encrypted:" + _encrypted
                 + " hasDataDescriptor:" + _hasDataDescriptor
                 + " hasCompressedPatchedData:" + _hasCompressedPatchedData
                 + " nameEncoding:" + _charSet
                 + " crc32:" + _crc32.toString(16)
                 + " adler32:" + _adler32.toString(16);
                 + "]" ;
        }
        
        ///////////// protected
        
        /**
         * Compress the zip file.
         * @private
         */
        protected function compress():void 
        {
            if( !isCompressed ) 
            {
                if(_data.length > 0) 
                {
                    _data.position = 0;
                    _sizeUncompressed = _data.length;
                    if( HAS_INFLATE ) 
                    {
                        _data.compress.apply( _data , ["deflate"] ) ;
                        _sizeCompressed = _data.length ;
                    }
                    else 
                    {
                        _data.compress();
                        _sizeCompressed = _data.length - 6 ;
                    }
                    _data.position = 0    ;
                    isCompressed   = true ;
                }
                else 
                {
                    _sizeCompressed = 0;
                    _sizeUncompressed = 0;
                }
            }
        }
        
        /**
         * @private
         */
        hack function parse( stream:IDataInput ):Boolean 
        {
            while ( stream.bytesAvailable && parseFunc(stream) )
            {
                //
            }
            return (parseFunc === parseFileIdle) ;
        }
        
        /**
         * @private
         */
        protected function parseContent( data:IDataInput) :void 
        {
            if( _compressionMethod === ZipCompression.DEFLATED && !_encrypted ) 
            {
                if( HAS_INFLATE ) 
                {
                    // Adobe Air supports inflate decompression. 
                    // If we got here, this is an Air application and we can decompress without using the Adler32 hack so we just write out the raw deflate compressed file
                    data.readBytes( _data, 0, _sizeCompressed ) ;
                } 
                else if( _hasAdler32 ) 
                {
                    // Add zlib header and CMF (compression method and info)
                    _data.writeByte(0x78) ;
                    // FLG (compression level, preset dict, checkbits)
                    var flg:uint = (~_deflateSpeedOption << 6) & 0xc0 ;
                    flg         += 31 - (((0x78 << 8) | flg) % 31);
                    _data.writeByte(flg);
                    // Add raw deflate-compressed file
                    data.readBytes( _data, 2, _sizeCompressed ) ;
                    // Add adler32 checksum
                    _data.position = _data.length;
                    _data.writeUnsignedInt( uint(_adler32) ) ;
                } 
                else 
                {
                    data.readBytes( _data , 0, _sizeCompressed); 
                    // TODO  throw new Error("Adler32 checksum not found.");
                }
                isCompressed = true;
            } 
            else if(_compressionMethod == ZipCompression.NONE) 
            {
                data.readBytes( _data, 0, _sizeCompressed ) ;
                isCompressed = false ;
            } 
            else 
            {
                throw new Error("Compression method " + _compressionMethod + " is not supported.") ;
            }
            _data.position = 0;
        }
        
        /**
         * Parse the external header of the zip file.
         * @private
         */
        protected function parseHeaderExternal(data:IDataInput):void 
        {
            if (_charSet == "utf-8") 
            {
                _name = data.readUTFBytes( _size ) ;
            } 
            else 
            {
                _name = data.readMultiByte(_size, _charSet) ;
            }
            var bytesLeft:uint = _sizeExtra ;
            while(bytesLeft > 4) 
            {
                var headerId:uint = data.readUnsignedShort() ;
                var dataSize:uint = data.readUnsignedShort() ;
                if(dataSize > bytesLeft) 
                {
                    throw new Error("Parse error in file " + _name + ": Extra field data size too big.");
                }
                if( headerId === 0xDADA && dataSize === 4 ) 
                {
                    _adler32    = data.readUnsignedInt() ;
                    _hasAdler32 = true ;
                }
                else if(dataSize > 0) 
                {
                    var extraBytes:ByteArray = new ByteArray() ;
                    data.readBytes(extraBytes, 0, dataSize) ;
                    _extraFields[headerId] = extraBytes ;
                }
                bytesLeft -= dataSize + 4;
            }
            if(bytesLeft > 0) 
            {
                data.readBytes(new ByteArray(), 0, bytesLeft ) ;
            }
        }
        
        /**
         * Parse the header of the zip file ByteArray.
         * @private
         */
        protected function parseHeader( data:IDataInput ):void 
        {
            _version           = Version.fromNumber( data.readUnsignedShort() >> 8 ) ;
            _flag              = data.readUnsignedShort() ;
            _compressionMethod = data.readUnsignedShort() ;
            _encrypted         = (_flag & 0x01) !== 0     ;
            
            _hasDataDescriptor = (_flag & 0x08) !== 0;
            _hasCompressedPatchedData = (_flag & 0x20) !== 0;
            
            if ( (_flag & 800) !== 0 ) 
            {
                _charSet = "utf-8" ;
            }
            
            if ( _compressionMethod === ZipCompression.IMPLODED ) 
            {
                _implodeDictSize         = (_flag & 0x02) !== 0 ? 8192 : 4096 ;
                _implodeShannonFanoTrees = (_flag & 0x04) !== 0 ?    3 :    2 ;
            } 
            else if ( _compressionMethod === ZipCompression.DEFLATED ) 
            {
                _deflateSpeedOption = (_flag & 0x06) >> 1 ;
            }
            
            ///////// FIXME use external tool class to convert dos time/date in timestamp
            
            var msdosTime:uint = data.readUnsignedShort() ;
            var msdosDate:uint = data.readUnsignedShort() ;
            var sec:int        = (   msdosTime & 0x001F ) ;
            var min:int        = (   msdosTime & 0x07E0 ) >> 5 ;
            var hour:int       = (   msdosTime & 0xF800 ) >> 11 ;
            var day:int        = (   msdosDate & 0x001F ) ;
            var month:int      = (   msdosDate & 0x01E0 ) >> 5 ;
            var year:int       = ( ( msdosDate & 0xFE00 ) >> 9 ) + 1980 ;
            
            _date = new Date( year , month - 1 , day , hour, min, sec, 0) ;
            
            _crc32            = data.readUnsignedInt() ;
            _sizeCompressed   = data.readUnsignedInt() ;
            _sizeUncompressed = data.readUnsignedInt() ;
            _size     = data.readUnsignedShort() ;
            _sizeExtra        = data.readUnsignedShort() ;
        }
        
        /**
         * Uncompress the zip file.
         * @private
         */
        protected function uncompress():void 
        {
            if( isCompressed && _data.length > 0 ) 
            {
                _data.position = 0;
                if( HAS_INFLATE ) 
                {
                    _data.uncompress.apply( _data, ["deflate"] ) ;
                } 
                else if(_hasAdler32)
                {
                    _data.uncompress() ;
                }
                else
                {
                    _data.deflate() ;
                }
                _data.position = 0   ;
                isCompressed = false ;
            }
        }
        
        /**
         * @private
         */
        hack var _adler32:uint ;
        
        /**
         * @private
         */
        hack var _comment:String ;
        
        /**
         * @private
         */
         hack var _compressionMethod:int = -1 ;
        
        /**
         * @private
         */
        hack var _crc32:uint ;
        
        /**
         * @private
         */
        hack var _data:ByteArray ;
        
        /**
         * @private
         */
        hack var _date:Date ;
        
        /**
         * @private
         */
        hack var _deflateSpeedOption:int = -1;
        
        /**
         * @private
         */
        hack var _encrypted:Boolean ;
        
        /**
         * @private
         */
        hack var _extra:ByteArray ;
        
        /**
         * @private
         */
        hack var _extraFields:Dictionary ;
        
        /**
         * @private
         */
        hack var _extraLength:uint ;
        
        /**
         * @private
         */
        hack var _name:String = "";
        
        /**
         * @private
         */
        hack var _charSet:String;
        
        /**
         * @private
         */
        hack var _flag:uint ;
        
        /**
         * @private
         */
        hack var _hasAdler32:Boolean ;
        
        /**
         * @private
         */
        hack var _hasDataDescriptor:Boolean ;
        
        /**
         * @private
         */
        hack var _hasCompressedPatchedData:Boolean ;
        
        /**
         * @private
         */
        hack var _implodeDictSize:int = -1 ;
        
        /**
         * @private
         */
        hack var _implodeShannonFanoTrees:int = -1 ;
        
        /**
         * @private
         */
        hack var isCompressed:Boolean ;
        
        /**
         * @private
         */
        hack var _nameLength:uint ;
        
        /**
         * @private
         */
        hack var _sizeCompressed:uint ;
        
        /**
         * @private
         */
        private var _sizeExtra:uint ;
        
        /**
         * @private
         */
        private var _size:uint ;
        
        /**
         * @private
         */
        hack var _sizeUncompressed:uint ;
        
        /**
         * @private
         */
        hack var _version:Version ;
        
        ///////////// private
         
        /**
         * @private
         */
        private var parseFunc:Function = parseFileHead;
        
        /**
         * @private
         */
        private static var HAS_INFLATE:Boolean = describeType(ByteArray).factory.method.(@name == "uncompress").hasComplexContent();
        
        /**
         * @private
         */
        private function parseFileContent(stream:IDataInput):Boolean 
        {
            if( _hasDataDescriptor ) 
            {
                parseFunc = parseFileIdle ; // Data descriptors are not supported
                throw new Error("Data descriptors are not supported.") ;
            }
            else if(_sizeCompressed == 0) 
            {
                parseFunc = parseFileIdle ; // This entry has no file attached
            } 
            else if(stream.bytesAvailable >= _sizeCompressed) 
            {
                parseContent(stream) ;
                parseFunc = parseFileIdle ;
            }
            else 
            {
                return false ;
            }
            return true ;
        }
        
        /**
         * @private
         */
        private function parseFileHead(stream:IDataInput):Boolean 
        {
            if( stream.bytesAvailable >= ZipTag.LOCHDR ) 
            {
                parseHeader(stream) ;
                if(_size + _sizeExtra > 0) 
                {
                    parseFunc = parseFileHeadExt ;
                } 
                else 
                {
                    parseFunc = parseFileContent ;
                }
                return true ;
            }
            return false ;
        }
        /**
         * @private
         */
        private function parseFileHeadExt(stream:IDataInput):Boolean 
        {
            if( stream.bytesAvailable >= _size + _sizeExtra ) 
            {
                parseHeaderExternal(stream) ;
                parseFunc = parseFileContent ;
                return true ;
            }
            return false ;
        }
        
        /**
         * @private
         */
        private function parseFileIdle(stream:IDataInput):Boolean 
        {
            return false;
        }
    }
}
