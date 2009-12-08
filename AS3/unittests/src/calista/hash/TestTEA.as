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
  ALCARAZ Marc (aka eKameleon)  <vegas@ekameleon.net>.
  Portions created by the Initial Developer are Copyright (C) 2004-2010
  the Initial Developer. All Rights Reserved.
  
  Contributor(s) :
  
*/

package calista.hash 
{
    import buRRRn.ASTUce.framework.TestCase;
    
    public class TestTEA extends TestCase 
    {
        public function TestTEA(name:String = "")
        {
            super(name);
        }
        
        public function testEncrypt():void
        {
            var source:String   = "hello world is secret" ;
            var password:String = "calista" ;
            assertEquals( TEA.encrypt( source , password ) , "021fd8983c171657403494ffe971fdbea3f48acea8418864" ) ;
        }
        
        public function testDecrypt():void
        {
            var source:String   = "hello world is secret" ; // "021fd8983c171657403494ffe971fdbea3f48acea8418864" ;
            var password:String = "calista" ;
            var encrypt:String = TEA.encrypt( source , password ) ;
            assertEquals( TEA.decrypt( encrypt , password ) , "hello world is secret" ) ; // FIXME bug must finalize this class in AS3
        }
    }
}
