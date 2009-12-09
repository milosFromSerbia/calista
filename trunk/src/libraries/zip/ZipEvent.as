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
    import system.events.BasicEvent;
    
    import flash.events.Event;
    
    /**
     * Zip dispatches ZipEvent objects.
     */
    public class ZipEvent extends BasicEvent
    {
        /**
         * Creates a new ZipEvent instance.
         * @param type the string type of the instance.
         * @param file The zip file reference of the event. 
         * @param target the target of the event.
         * @param context the optional context object of the event.
         * @param bubbles indicates if the event is a bubbling event.
         * @param cancelable indicates if the event is a cancelable event.
         * @param time this optional parameter is used in the eden deserialization to copy the timestamp value of this event.
         */
        public function ZipEvent(type:String, file:ZipFile = null, target:Object = null , context:* = null , bubbles:Boolean = false, cancelable:Boolean = false, time:uint = 0) 
        {
            this.file = file;
            super(type, target, context, bubbles, cancelable, time);
        }
        
        /**
         * Defines the value of the type property of a ZipEvent object.
         */
        public static const FILE_LOADED:String = "fileLoaded" ;
        
        /**
        * The file that has finished loading.
        */
        public var file:ZipFile;
        
        /**
         * Returns the shallow copy of this event.
         * @return the shallow copy of this event.
         */
        public override  function clone():Event 
        {
            return new ZipEvent(type, file, target, context, bubbles, cancelable, timeStamp);
        }
    }
}