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
    import system.data.Map;
    import system.data.maps.HashMap;
    import system.hack;
    import system.process.ActionURLStream;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLStream;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    
    /**
     * Loads and parses ZIP archives. This task can be used like a process only with the external stream process, not with the loadBytes() method.
     */
    public class ZipArchive extends ActionURLStream
    {
        use namespace hack ;
        
        /**
         * Creates a new ZipReference instance.
         * @param encoding The encoding type of the name of the zip file (default utf-8).
         */
        public function ZipArchive( charSet:String = "utf-8" )
        {
            super( new URLStream() ) ;
            _charSet = charSet ;
            _files   = new HashMap() ;
            _parser  = parseIdle ;
        }
        
        /**
         * Indicates whether a file is currently being processed or not.
         */
        public function get active():Boolean 
        {
            return _parser !== parseIdle ;
        }
        
        /**
         * Indicates the number of files in the zip archive.
         */
        public function get numFiles():uint
        {
            return _elements.length ;
        }
        
        /**
         * Adds a file to the zip archive.
         * @param name The name of the file.
         * @param content The ByteArray containing the uncompressed data (pass <code>null</code> to add a folder).
         * @return A reference to the newly created ZipFile object.
         */
        public function addFile(name:String, content:ByteArray = null):ZipFile 
        {
            return addFileAt( _elements ? _elements.length : 0 , name , content ) as ZipFile ;
        }
        
        /**
         * Adds a file to the zip archive, at a specified index.
         * @param index The index of the file to insert in the zip archive.
         * @param name The name of the file.
         * @param content The ByteArray containing the uncompressed data (pass <code>null</code> to add a folder).
         * @return A reference to the newly created ZipFile object.
         */
        public function addFileAt(index:uint, name:String, content:ByteArray = null):ZipFile 
        {
            if(_elements == null) 
            {
                _elements = new Vector.<ZipFile>() ;
            }
            if( _files == null ) 
            {
                _files = new HashMap() ;
            } 
            else if( _files.containsKey(name ) ) 
            {
                throw new Error( this + " addFileAt(" + index + "," + name + ",...) failed, the file already exists with the name:'" + name + "'. Please remove first.") ;
            }
            var file:ZipFile = new ZipFile();
            file.name    = name ;
            file.content = content;
            if( index >= _elements.length ) 
            {
                _elements.push(file) ;
            } 
            else 
            {
                _elements.splice(index, 0, file);
            }
            _files.put( name , file ) ;
            return file;
        }
        
        /**
         * Adds a file from a String to the zip archive.
         * @param index The index of the file in the archive.
         * @param name The name of the file.
         * @param content The String to transform in a new file in the archive.
         * @param charset The character set of the file.
         * @return A reference to the newly created ZipFile object.
         */
        public function addFileFromString(name:String, content:String, charset:String = "utf-8" ):ZipFile 
        {
            return addFileFromStringAt( _elements ? _elements.length : 0, name, content, charset) ;
        }
        
        /**
         * Adds a file from a String to the zip archive at a specified index.
         * @param index The index of the file in the archive.
         * @param name The name of the file.
         * @param content The String to transform in a new file in the archive.
         * @param charset The character set of the file.
         * @return A reference to the newly created ZipFile object.
         */
        public function addFileFromStringAt( index:uint , name:String , content:String = "" , charset:String = "utf-8" ):ZipFile 
        {
            if(_elements == null) 
            {
                _elements = new Vector.<ZipFile>() ;
            }
            if( _files == null ) 
            {
                _files = new HashMap() ;
            }
            else if( _files.containsKey(name ) ) 
            {
                throw new Error(this + " addFileAt(" + index + "," + name + ",...) failed, the file already exists with the name:'" + name + "'. Please remove first.") ;
            }
            var file:ZipFile = new ZipFile();
            file.name = name;
            file.setContentAsString( content , charset ) ;
            if( index >= _elements.length ) 
            {
                _elements.push(file) ;
            } 
            else 
            {
                _elements.splice(index, 0, file);
            }
            _files.put( name , file ) ;
            return file;
        }
        
        /**
         * Immediately closes the stream and cancels the download operation.
         * Files contained in the ZIP archive being loaded stay accessible through the getFileAt() and getFileByName() methods.
         */
        public override function close():void 
        {
            _parser = parseIdle;
            super.close() ;
        }
        
        /**
         * Retrieves a file contained in the ZIP archive, by name.
         * @param index The specified index to find a ZipFile object in the archive.
         * @return A reference to a ZipFile object if is exist.
         */
        public function getFileAt( index:uint ):ZipFile 
        {
            return _elements[index] as ZipFile ;
        }
        
        /**
         * Retrieves a file contained in the ZIP archive, by name.
         * @param name The name of the file to retrieve.
         * @return A reference to a ZipFile object
         */
        public function getFileByName( name:String ):ZipFile 
        {
            return _files.get( name ) as ZipFile ;
        }
        
        /**
         * Loads a ZIP archive from a ByteArray.
         * @param bytes The ByteArray containing the ZIP archive
         */
        public function loadBytes(bytes:ByteArray):void 
        {
            if (!_loader && _parser == parseIdle) 
            {
                _elements      = new Vector.<ZipFile>() ;
                _files         = new HashMap() ;
                _parser        = parseSignature ;
                bytes.position = 0;
                bytes.endian   = Endian.LITTLE_ENDIAN;
                if ( parse(bytes) ) 
                {
                    _parser = parseIdle;
                    dispatchEvent( new Event(Event.COMPLETE) ) ;
                } 
                else 
                {
                    dispatchEvent( new ZipErrorEvent( ZipErrorEvent.PARSE_ERROR, "EOF") ) ;
                }
            }
        }
        
        /**
         * Unregisters the loader object.
         */
        public override function register( dispatcher:IEventDispatcher ):void
        {
            if ( dispatcher != null )
            { 
                dispatcher.addEventListener( IOErrorEvent.IO_ERROR             , _error    , false, 0, true ) ;
                dispatcher.addEventListener( SecurityErrorEvent.SECURITY_ERROR , _error    , false, 0, true ) ;
                dispatcher.addEventListener( ProgressEvent.PROGRESS            , _progress , false, 0, true ) ;
                super.register( dispatcher ) ;
            }
        }
        
        /**
         * Removes a file at a specified index from the zip archive.
         * @param index The index to remove a file
         * @return A reference to the removed ZipFile object.
         */
        public function removeFileAt(index:uint):ZipFile 
        {
            if( _elements != null && _files != null && index < _elements.length) 
            {
                var file:ZipFile = _elements[index] as ZipFile ;
                if( file != null ) 
                {
                    _elements.splice(index, 1);
                    if ( file.name != null && _files.containsKey( file.name ) )
                    {
                        _files.remove( file.name ) ;
                    }
                    return file ;
                }
            }
            return null;
        }
        
        /**
         * Serializes this zip archive into an IDataOutput stream (such as ByteArray or FileStream) according to PKZIP APPNOTE.TXT.
         * @param stream The stream to serialize the zip file into.
         * @param includeAdler32 To decompress compressed files, Zip needs Adler32 checksums to be injected into the zipped files. 
         * Zip will do that automatically if includeAdler32 is set to true. Note that if the zip contains a lot of files, or big files, the calculation of the checksums may take a while.
         */
        public function serialize( stream:IDataOutput , includeAdler32:Boolean = false ):void 
        {
            var len:uint = _elements.length ;
            if( stream != null && len > 0 ) 
            {
                var endian:String = stream.endian  ;
                var ba:ByteArray = new ByteArray() ;
                var offset:uint ;
                var files:uint  ;
                var file:ZipFile ;
                
                stream.endian = ba.endian = Endian.LITTLE_ENDIAN;
                
                for( var i:int ; i < len ; i++ ) 
                {
                    file = _elements[i] as ZipFile;
                    if( file != null ) 
                    {
                        file.serialize( ba , includeAdler32 , true , offset ) ; // serialize the central directory item into our temporary ByteArray
                        offset += file.serialize(stream, includeAdler32 ) ; // serialize the file itself into the stream and update the offset
                        files++ ; // keep track of how many files we have written
                    }
                }
                if( ba.length > 0 ) 
                {
                    stream.writeBytes(ba); // Write the central diectory items
                }
                // Write end of central directory:
                // Write signature
                stream.writeUnsignedInt( ZipTag.ENDSIG );
                // Write number of this disk (always 0)
                stream.writeShort(0);
                // Write number of this disk with the start of the central directory (always 0)
                stream.writeShort(0);
                // Write total number of entries on this disk
                stream.writeShort(files);
                // Write total number of entries
                stream.writeShort(files);
                // Write size
                stream.writeUnsignedInt(ba.length);
                // Write offset of start of central directory with respect to the starting disk number
                stream.writeUnsignedInt(offset);
                // Write zip file comment length (always 0)
                stream.writeShort(0);
                // Reset endian of stream
                stream.endian = endian;
            }
        }
        
        /**
         * Unregisters the loader object.
         */
        public override function unregister( dispatcher:IEventDispatcher ):void
        {
            if ( dispatcher != null )
            { 
                dispatcher.removeEventListener( IOErrorEvent.IO_ERROR             , _error    ) ;
                dispatcher.removeEventListener( SecurityErrorEvent.SECURITY_ERROR , _error    ) ;
                dispatcher.removeEventListener( ProgressEvent.PROGRESS            , _progress ) ;
                super.unregister( dispatcher ) ;
            }
        }
        
        /**
         * @private
         */
        protected function parse( stream:IDataInput ):Boolean 
        {
            while ( _parser(stream) ) 
            {
                //
            }
            return ( _parser === parseIdle ) ;
        }
        
        /**
         * @private
         */
        protected function _error( e:ErrorEvent ):void 
        {
            _parser = parseIdle;
            if ( _loader != null && _loader is URLStream )
            {
                (_loader as URLStream).close() ;
            }
        }
        
        /**
         * Invoked when the stream is in progress.
         * @private
         */
        protected function _progress( e:ProgressEvent ):void
        {
            try 
            {
                var stream:URLStream = _loader as URLStream ;
                if( parse( stream ) ) 
                {
                    close();
                    dispatchEvent( new Event( Event.COMPLETE ) ) ;
                }
            } 
            catch( error:Error ) 
            {
                close();
                dispatchEvent( new ZipErrorEvent( ZipErrorEvent.PARSE_ERROR, error.message ) ) ;
            }
        }
        
        /**
         * This protected method contains the invokation of the load method of the current loader of this process.
         */
        protected override function _run():void
        {
            var stream:URLStream = _loader as URLStream ;
            if ( stream != null && ( _parser == parseIdle ) )
            { 
                _elements = new Vector.<ZipFile>() ;
                _files    = new HashMap() ;
                _parser   = parseSignature ;
                stream.endian = Endian.LITTLE_ENDIAN ;
                stream.load( request ) ;
            }
        }
        
        /**
         * @private
         */
        private var _charSet:String ;
        
        /**
         * @private
         */
        private var _current:ZipFile ;
        
        /**
         * @private
         */
        private var _elements:Vector.<ZipFile> ;
        
        /**
         * @private
         */
        private var _files:Map ;
        
        /**
         * @private
         */
        private var _parser:Function ;
        
        /**
         * @private
         */
        private function parseIdle( stream:IDataInput ):Boolean 
        {
            return false;
        }
        
        /**
         * @private
         */
        private function parseLocalfile(stream:IDataInput):Boolean 
        {
            if( _current.parse(stream) ) 
            {
                _elements.push( _current );
                if ( _current.name ) 
                {
                    _files.put( _current.name , _current ) ;
                }
                dispatchEvent( new ZipEvent( ZipEvent.FILE_LOADED, _current ) ) ;
                _current = null;
                if (_parser != parseIdle) 
                {
                    _parser = parseSignature ;
                    return true ;
                }
            }
            return false;
        }
        
        /**
         * @private
         */
        private function parseSignature(stream:IDataInput):Boolean 
        {
            if(stream.bytesAvailable >= 4) 
            {
                var signature:uint = stream.readUnsignedInt() ;
                switch( signature ) 
                {
                    case ZipTag.LOCSIG :
                    {
                        _parser  = parseLocalfile;
                        _current = new ZipFile( _charSet );
                        break;
                    }
                    case ZipTag.CENSIG :
                    case ZipTag.ENDSIG :
                    {
                        _parser = parseIdle ;
                        break;
                    }
                    default :
                    {
                        throw(new Error("Unknown record signature."));
                    }
                }
                return true ;
            }
            return false;
        }
    }
}
