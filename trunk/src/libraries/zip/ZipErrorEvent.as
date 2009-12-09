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
    import flash.events.ErrorEvent;
    import flash.events.Event;
    
    /**
     * The Zip class dispatches ZipErrorEvent objects when it encounters errors while parsing the ZIP archive. 
     * There is only one type of ZipErrorEvent : ZipErrorEvent.PARSE_ERROR
     */
    public class ZipErrorEvent extends ErrorEvent
    {
        /**
         * Creates a new ZipErrorEvent
         * @param type The type of the event.
         * @param text A description of the kind of parse error.
         * @param bubbles Determines whether the Event object participates in the bubbling stage of the event flow. Event listeners can access this information through the inherited bubbles property.
         * @param cancelable Determines whether the Event object can be canceled. Event listeners can access this information through the inherited cancelable property.
         */
        public function ZipErrorEvent( type:String , text:String = "", bubbles:Boolean = false, cancelable:Boolean = false ) 
        {
            super(type, bubbles, cancelable, text ) ;
        }
        
        /**
         * Defines the value of the type property of a FZipErrorEvent object.
         */
        public static const PARSE_ERROR:String = "parseError";
        
        /**
         * Returns the shallow copy of the object.
         * @return the shallow copy of the object.
         */
        public override function clone():Event 
        {
            return new ZipErrorEvent( type , text , bubbles , cancelable ) ;
        }
    }
}
