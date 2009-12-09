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
    import calista.hash.Adler32;
    
    import flash.display.Sprite;
    import flash.utils.ByteArray;
    
    public class Adler32Example extends Sprite 
    {
        public function Adler32Example()
        {
            var bytes:ByteArray = new ByteArray() ;
            bytes.writeUTFBytes("Wikipedia") ;
            
            var sum:uint = Adler32.checkSum(bytes) ;
            
            trace("Adler32 : " + sum + " 0x" + sum.toString( 16 ).toUpperCase() ) ; // Adler32 : 300286872 0x11E60398
        }
    }
}
