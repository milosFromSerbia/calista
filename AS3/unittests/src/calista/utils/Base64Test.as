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

package calista.utils
{
    import buRRRn.ASTUce.framework.TestCase;
    
    import graphics.display.ByteArrays;
    
    import flash.utils.ByteArray;
    
    /**
     * This class test the Base64 class.
     */
    public class Base64Test extends TestCase 
    {
        public function Base64Test( name : String="" )
        {
            super( name );
        }
        
        public function testEncode():void
        {
            var encode:String = Base64.encode( "hello world with a base 64 algorithm" ) ;
            assertEquals( encode ,  "aGVsbG8gd29ybGQgd2l0aCBhIGJhc2UgNjQgYWxnb3JpdGht" ) ;
        }
        
        public function testEncodeByteArray():void
        {
            var source:String   = "hello world with a base 64 algorithm" ;
            var bytes:ByteArray = new ByteArray();
            
            bytes.writeUTFBytes(source) ;
            
            var result:String = Base64.encodeByteArray( bytes ) ;
            assertEquals( result ,  "aGVsbG8gd29ybGQgd2l0aCBhIGJhc2UgNjQgYWxnb3JpdGht" ) ;
        }
        
        public function testDecode():void
        {
            var decode:String = Base64.decode( "aGVsbG8gd29ybGQgd2l0aCBhIGJhc2UgNjQgYWxnb3JpdGht" ) ;
            assertEquals( decode ,  "hello world with a base 64 algorithm" ) ;
        }
        
        public function testDecodeByteArray():void
        {
            var bytes:ByteArray = new ByteArray() ;
            bytes.writeUTFBytes("hello world with a base 64 algorithm") ;
            var result:ByteArray  = Base64.decodeToByteArray( "aGVsbG8gd29ybGQgd2l0aCBhIGJhc2UgNjQgYWxnb3JpdGht" ) ;
            assertTrue( ByteArrays.equals(bytes, result) ) ;
        }
    }
}