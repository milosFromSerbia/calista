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
  
*/

package examples 
{
    import calista.hash.SHA1;

    import flash.display.Sprite;

    public class SHA1Example extends Sprite 
    {
        public function SHA1Example()
        {
            var hash:String = SHA1.encrypt("hello world") ;
            var equal:Boolean = hash == '2aae6c35c94fcfb415dbe95f408b9ce91ee846ed' ;
            trace("'hello world' SHA1 result : " + hash + " : " + equal ) ;
        }
    }
}
