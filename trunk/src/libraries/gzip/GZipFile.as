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
    import flash.utils.ByteArray;
    
    /**
     * Defines an helper to manipulate files compressed with the GZip algorithm.
     */
    public class GZipFile 
    {
        /**
         * Creates a new GZipFile instance.
         * @param data The compressed data value.
         */
        public function GZipFile( data:ByteArray , originalSize:uint, modificationDate:Date , name:String = "", headerFileName:String = null, headerComment:String = null)
        {
            _data             = data ;
            _originalSize     = originalSize ;
            _modificationDate = modificationDate ;
            _name             = name ;
            _headerFilename   = headerFileName ;
            _headerComment    = headerComment ;
        }
        
        /**
         * The date that the file was last modified.
         */
        public function get modificationDate ():Date
        {
            return _modificationDate ;
        }
        
        /**
         * The name of the file.
         */
        public function get name():String
        {
            return _name ;
        }
        
        /**
         * The header file name of the file.
         */
        public function get headerFilename():String
        {
            return _headerFilename;
        }
        
        /**
         * The header comment of the file.
         */
        public function get headerComment():String
        {
            return _headerComment;
        }
        
        /**
         * The size of the file in bytes.
         */
        public function get originalSize():uint
        {
            return _originalSize ;
        }
        
        /**
         * Retrieves a copy of the compressed data bytes extracted from the GZIP file. 
         * <p>Call the <code>ByteArray.inflate()</code> method on the result for the uncompressed data.</p>
         * <p>Modifications to the result ByteArray, including uncompressing, do not alter the result of future calls to this method.</p>
         * @see flash.data.ByteArray#inflate()
         */
        public function get data():ByteArray
        {
            var result:ByteArray = new ByteArray();
            _data.position = 0;
            _data.readBytes( result, 0, _data.length ) ;
            return result;
        }
        
        /**
         * @private
         */
        private var _data:ByteArray;
        
        /**
         * @private
         */
        private var _headerComment:String;
        
        /**
         * @private
         */
        private var _headerFilename:String;
        
        /**
         * @private
         */
        private var _modificationDate:Date;
        
        /**
         * @private
         */
        private var _name:String;
        
        /**
         * @private
         */
        private var _originalSize:uint;
    }
}
