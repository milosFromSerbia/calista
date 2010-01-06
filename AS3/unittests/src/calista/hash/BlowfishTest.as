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

package calista.hash 
{
    import buRRRn.ASTUce.framework.TestCase;

    import system.hack;
    use namespace hack ;
    
    public class BlowfishTest extends TestCase 
    {
        public function BlowfishTest(name:String = "")
        {
            super(name);
        }
        
        public function testKey():void
        {
            var blowfish:Blowfish = new Blowfish("calista") ;
            assertEquals( "63616C69737461" , blowfish.key ) ;
        }
        
        public function testEncrypt():void
        {
            var blowfish:Blowfish = new Blowfish("calista") ;
            assertEquals( "09B162A36AF69F66699E5BAE6CF11B3C" , blowfish.encrypt( "hello world" ) ) ;
        }
        
        public function testEncryptWithNewKey():void
        {
            var blowfish:Blowfish = new Blowfish("calista") ;
            blowfish.key = "secret" ;
            assertEquals( "125A0CCBD0F1FFA68B974D062C8BF4A6" , blowfish.encrypt( "hello world" ) ) ;
        }
        
        public function testDecrypt():void
        {
            var blowfish:Blowfish = new Blowfish("calista") ;
            assertEquals( "hello world" , blowfish.decrypt( "09B162A36AF69F66699E5BAE6CF11B3C" ) ) ;
        }
        
        public function testDecryptWithNewKey():void
        {
            var blowfish:Blowfish = new Blowfish("calista") ;
            blowfish.key = "secret" ;
            assertEquals( "hello world" , blowfish.decrypt( "125A0CCBD0F1FFA68B974D062C8BF4A6" ) ) ;
        }
        
        public function testEscape():void
        {
            var blowfish:Blowfish = new Blowfish() ;
            assertEquals("63616C69737461" , blowfish.escape( "calista" )) ;
        }
        
        public function testUnEscape():void
        {
            var blowfish:Blowfish = new Blowfish() ;
            assertEquals( "calista" , blowfish.unescape( "63616C69737461" )) ;
        }
        
        public function testWordescape():void
        {
            var blowfish:Blowfish = new Blowfish() ;
            assertEquals("01000000" , blowfish.wordescape( 1 )) ;
            assertEquals("0A000000" , blowfish.wordescape( 10 )) ;
        }
        
        public function testWordunescape():void
        {
            var blowfish:Blowfish = new Blowfish() ;
            assertEquals(  1 , blowfish.wordunescape( "01000000") ) ;
            assertEquals( 10 , blowfish.wordunescape( "0A000000") ) ;
        }
        
        public function testXor():void
        {
            var blowfish:Blowfish = new Blowfish() ;
            assertEquals(  0 , blowfish.xor( 1 ,  1 ) ) ;
            assertEquals( 11 , blowfish.xor( 1 , 10 ) ) ;
            assertEquals( 21 , blowfish.xor( 1 , 20 ) ) ;
            assertEquals(  8 , blowfish.xor( 2 , 10 ) ) ;
            assertEquals( 23 , blowfish.xor( 3 , 20 ) ) ;
        }
    }
}
