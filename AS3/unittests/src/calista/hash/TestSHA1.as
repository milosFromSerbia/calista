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
    
    public class TestSHA1 extends TestCase 
    {
        public function TestSHA1(name:String = "")
        {
            super(name);
        }
        
        public function testEncrypt():void
        {
            assertEquals( SHA1.encrypt("hello world") , '2aae6c35c94fcfb415dbe95f408b9ce91ee846ed' ) ;
        }
    }
}
