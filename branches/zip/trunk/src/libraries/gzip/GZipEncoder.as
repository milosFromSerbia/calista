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
    import flash.errors.IllegalOperationError;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    import flash.utils.CompressionAlgorithm;
    
    public class GZipEncoder 
    {
        /**
         * Writes a GZIP compressed file format file to a file stream.
         * <p>This particular method takes a "least effort" approach, meaning any optional metadata fields are not included in the GZIP file that's written to disk.</p>
         * @param source The source data to compress and embed in the GZIP file. The source can be a file on the filesystem (a File instance), 
         * in which case the contents of the file are read, compressed, and output to the file stream. Alternatively, the source can be a ByteArray instance, 
         * in which case the ByteArray's contents are compressed and output to the file stream.
         * @param output The File location to which the compressed GZIP format file should be written.
         * The user should have permission to write to the file location. If the location
         * specifies a file name, that file name will be used. If the output location is
         * a directory, a new file will be created with the name "[src file name].gz". If src
         * is a ByteArray, and output only specifies a directory, the output file will
         * be created with the name "output.gz".
         * @throws ArgumentError If the <code>source</code> argument is not a File or ByteArray instance; if the <code>src</code> argument refers to a directory or a non-existent file;  or if either argument is null.
         */
        public function compressToFile( source:Object , output:File ):void
        {
            if (source == null || output == null)
            {
                throw new ArgumentError("source and output can't be null.");
            }
            var bytes:ByteArray;
            var target:File = new File(output.nativePath);
            var date:Date;
            if (source is File)
            {
                var file:File = source as File;
                if (!file.exists || file.isDirectory)
                {
                    throw new ArgumentError("If 'source' is a File instance, it must specify the location of an existing file (not a directory).");
                }
                
                var stream:FileStream = new FileStream();
                
                stream.open(file, FileMode.READ);
                
                bytes = new ByteArray();
                stream.readBytes(bytes, 0, stream.bytesAvailable);
                stream.close();
                
                if (target.isDirectory)
                {
                    target = target.resolvePath(file.name + ".gz");
                }
                date = file.modificationDate ;
            }
            else if (source is ByteArray)
            {
                bytes = source as ByteArray;
                if (target.isDirectory)
                {
                    target = target.resolvePath("output.gz") ;
                }
                date = new Date() ;
            }
            else
            {
                throw new ArgumentError("The source must be a File instance or a ByteArray instance");
            }
            var gzipBytes:ByteArray  = _bytesEncoder.compressToByteArray( bytes , date ) ;
            var outStream:FileStream = new FileStream();
            outStream.open( target , FileMode.WRITE );
            outStream.writeBytes( gzipBytes , 0 , gzipBytes.length ) ;
            outStream.close() ;
        }
        
        /**
         * Uncompresses a GZIP-compressed-format file to another file location.
         * @param source The filesystem location of the GZip format file to uncompress.
         * @param output The filesystem location where the uncompressed file should be saved.
         * If <code>output</code> specifies a file name, that file name will be used
         * for the new file, regardless of the original file name. If the argument
         * specifies a directory, the uncompressed file will be saved in that directory. In
         * that case, if the GZIP file includes file name information, the new file will
         * be saved with the original file name; if no file name is present, the new file
         * will be saved with the name of the source GZIP file, minus the ".gz" or ".gzip" extension.
         * @throws ArgumentError If <code>source</code> or <code>output</code> argument is null; 
         * if <code>source</code> is a directory rather than a file; or
         * if <code>source</code> points to a file location that doesn't exist.
         */
        public function uncompressToFile(source:File, output:File):void
        {
            if (output == null)
            {
                    throw new ArgumentError("output cannot be null");
            }
            var gzipData:GZipFile = parseGZIPFile( source ) ;
            var outFile:File      = new File(output.nativePath);
            if (outFile.isDirectory)
            {
                var fileName:String;
                if (gzipData.headerFilename != null)
                {
                    fileName = gzipData.headerFilename;
                }
                else if (gzipData.name.lastIndexOf(".gz") == gzipData.name.length - 3)
                {
                    fileName = gzipData.name.substr(0, gzipData.name.length - 3);
                }
                else if (gzipData.name.lastIndexOf(".gzip") == gzipData.name.length - 5)
                {
                    fileName = gzipData.name.substr(0, gzipData.name.length - 5);
                }
                else
                {
                    fileName = gzipData.name;
                }
                outFile = outFile.resolvePath(fileName);
            }
            var data:ByteArray = gzipData.data;
            try
            {
                data.uncompress( CompressionAlgorithm.DEFLATE ) ;
            }
            catch (error:Error)
            {
                throw new IllegalOperationError("The specified file is not a GZIP file format file.");
            }
            var outStream:FileStream = new FileStream() ;
            outStream.open(outFile, FileMode.WRITE) ;
            outStream.writeBytes(data, 0, data.length) ;
            outStream.close() ;
        }
        
        /**
         * Uncompresses a GZIP-compressed-format file to a ByteArray object.
         * @param source The location of the source file to uncompress, or theByteArray object to uncompress.
         * The source can be a file on the filesystem (a File instance), in which case the contents of the file are read, uncompressed, and output as the result.
         * Alternatively, the source can be a ByteArray instance, in which case the ByteArray's contents are uncompressed and output as the result. 
         * In either case the <code>source</code> object must be compressed using the GZIP file format.
         * @returns A ByteArray containing the uncompressed bytes that were compressed and encoded in the source file or ByteArray.
         * @throws ArgumentError If the <code>source</code> argument is not a File or ByteArray instance; 
         * if the <code>source</code> argument refers to a directory or a non-existent file;  or if either argument is null.
         * @throws IllegalOperationError If the specified file or ByteArray is not GZIP-format file or data.
         */
        public function uncompressToByteArray( source:Object ):ByteArray
        {
            var gzipData:GZipFile;
            if (source is File)
            {
                gzipData = parseGZIPFile( source as File );
            }
            else if ( source is ByteArray )
            {
                gzipData = parseGZIPData( source as ByteArray ) ;
            }
            else
            {
                throw new ArgumentError("The source argument must be a File or ByteArray instance");
            }
            var data:ByteArray = gzipData.data ;
            try
            {
                data.uncompress( CompressionAlgorithm.DEFLATE ) ;
            }
            catch (error:Error)
            {
                throw new IllegalOperationError("The specified source is not a GZIP file format file or data.");
            }
            return data;
        }
        
        /**
         * Parses a GZip format file into an object with properties representing the important characteristics of the GZIP file
         * (the header and footer metadata, as well as the actual compressed data).
         * @param source   The filesystem location of the GZIP file to parse.
         * @returns An object containing the information from the source GZip file.
         * @throws ArgumentError If the <code>source</code> argument is null; refers to a directory; or refers to a file that doesn't exist.
         * @throws IllegalOperationError If the specified file is not a GZip format file.
         */
        public function parseGZIPFile( source:File ):GZipFile
        {
            _checkFile( source ) ;
            
            var file:File         = new File(source.nativePath);
            var stream:FileStream = new FileStream();
            
            stream.open( file , FileMode.READ ) ;
            
            var bytes:ByteArray = new ByteArray();
            
            stream.readBytes( bytes , 0 , stream.bytesAvailable ) ;
            stream.close() ;
            
            return parseGZIPData( bytes, file.name) ;
        }
        
        /**
         * Parses a GZip format ByteArray into an object with properties representing the important
         * characteristics of the GZip data (the header and footer metadata, as well as the actual compressed data).
         * <p>This method is simply a wrapper for the <code>GZIPBytesEncoder.parseGZIPData()</code> method.</p>
         * @param source The ByteArray of the GZIP data to parse.
         * @param name The name of the GZIP file.
         * @returns An object containing the information from the source GZip data.
         * @throws ArgumentError If the <code>source</code> argument is null.
         * @throws IllegalOperationError If the specified data is not in GZip format.
         */
        public function parseGZIPData( source:ByteArray, name:String = ""):GZipFile
        {
            return _bytesEncoder.parseGZIPData(source, name);
        }
        
        /**
         * @private
         */
        private var _bytesEncoder:GZipBytesEncoder = new GZipBytesEncoder();
        
        /**
         * @private
         */
        private function _checkFile( source:File ):void
        {
            if (source == null)
            {
                throw new ArgumentError("The source can't be null");
            }
            if ( source.isDirectory )
            {
                throw new ArgumentError("The source must refer to the location of a file, not a directory");
            }
            if ( !source.exists )
            {
                throw new ArgumentError("The source refers to a file that doesn't exist");
            }
        }
    }
}
