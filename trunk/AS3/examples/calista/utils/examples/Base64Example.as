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
	import graphics.display.ByteArrays;
    import calista.utils.Base64;
    
    import flash.display.Sprite;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
    
    public class Base64Example extends Sprite 
    {
        public function Base64Example()
        {
            var source:String ;
            var encode:String ;
            var decode:String ;
            
            source = "hello world with a base 64 algorithm" ;
           
            var bytes:ByteArray ;
            
            bytes = new ByteArray();
            bytes.writeUTFBytes(source);
            
            var i:int ;
            var timer:int ;
            
            var loop:int = 5000 ;
            
            timer = getTimer() ;
            for( i = 0 ; i<loop ; i++ )
            {
                encode = Base64.encode( source ) ;
                decode = Base64.decode( encode ) ;
               
            }
            timer = getTimer() - timer ;
            trace("encode : " + encode + " timer:" + timer + " ms") ;
            trace("decode : " + decode + " timer:" + timer + " ms") ;
            
            var result:ByteArray ;
            
            timer = getTimer() ;
            for( i = 0 ; i<loop ; i++ )
            {
                encode = Base64.encodeByteArray( bytes ) ;
                result = Base64.decodeToByteArray( encode ) ;
            }
            timer = getTimer() - timer ;
            trace("encode : " + encode + " timer:" + timer + " ms") ;
            trace("bytes  : " + ByteArrays.equals(bytes, result)  + " timer:" + timer + " ms") ;
        }
    }
}
