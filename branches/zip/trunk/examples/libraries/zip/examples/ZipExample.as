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

package examples 
{
    import libraries.zip.ZipArchive;
    import libraries.zip.ZipFile;
    
    import system.console;
    import system.diagnostics.TextFieldConsole;
    import system.events.ActionEvent;
    
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    [SWF(width="980", height="700", frameRate="30", backgroundColor="0x333333")]
    
    /**
     * Example with the zip class.
     */
    public class ZipExample extends Sprite 
    {
        public function ZipExample()
        {
            ///////////
            
            stage.align     = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            ///////////
            
            var format:TextFormat = new TextFormat( "Courier New" , 14 , 0xFFFFFF ) ;
            
            format.leftMargin = 4 ;
            
            textfield                   = new TextField() ;
            textfield.defaultTextFormat = format ;
            textfield.multiline         = true ;
            textfield.selectable        = true ;
            textfield.wordWrap          = true ;
            
            addChild( textfield ) ;
            
            stage.addEventListener( Event.RESIZE , resize ) ;
            resize() ;
            
            console = new TextFieldConsole( textfield ) ;
            
            ///////////
            
            container = new Sprite() ;
            
            container.x = 390 ;
            container.y =  25 ;
            
            addChild( container ) ;
            
            ///////////
            
            zip = new ZipArchive();
            
            zip.addEventListener( ActionEvent.FINISH , debug ) ;
            zip.addEventListener( ActionEvent.START  , debug ) ;
            
            zip.addEventListener( Event.COMPLETE        , complete ) ;
            zip.addEventListener( Event.OPEN            , open     ) ;
            zip.addEventListener( IOErrorEvent.IO_ERROR , error    ) ;
            zip.addEventListener( SecurityErrorEvent.SECURITY_ERROR , error ) ;
            
            zip.request = new URLRequest("library/icons.zip") ;
            
            console.writeLine("# zip load uri:" + zip.request.url ) ;
            
            zip.run();
        }
        
        protected var container:Sprite ;
        protected var count:uint ;
        protected var done:Boolean ;
        protected var index:uint ;
        protected var textfield:TextField;
        protected var zip:ZipArchive;
        
        protected function debug( e:Event ):void 
        {
            console.writeLine( "# " + e.type ) ;
        }
        
        protected function complete( e:Event ):void 
        {
            console.writeLine( "# complete" ) ;
            done = true ;
        }
        
        protected function error( e:ErrorEvent ):void 
        {
            console.writeLine( "# error : " + e.text ) ;
        }
        
        protected function enterFrame( e:Event = null ):void 
        {
            for( var i:uint ; i < 50 ; i++ ) 
            {
                if( zip.numFiles > index ) 
                {
                    var file:ZipFile = zip.getFileAt(index) ;
                    if( file.name.indexOf("icons/") == 0 && file.name.indexOf(".png") != -1 ) 
                    {
                        console.writeLine( "  > add : " + file.name ) ;
                        
                        var loader:Loader = new Loader() ;
                        
                        loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR , error ) ;
                        loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, error ) ;
                        
                        loader.loadBytes( file.content ) ;
                        
                        loader.x = 18 * (count % 32) ;
                        loader.y = 18 * Math.floor(count / 32) + 20;
                        
                        container.addChild(loader);
                        
                        count++ ;
                    }
                    index++;
                } 
                else 
                {
                    if( done ) 
                    {
                        removeEventListener(Event.ENTER_FRAME, enterFrame);
                    }
                }
            }
            console.writeLine( "# " + count + " files loaded" ) ;
        }
        
        protected function open( e:Event ):void 
        {
            console.writeLine( "# open" ) ;
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        protected function resize( e:Event = null ):void
        {
            textfield.width  = stage.stageWidth ;
            textfield.height = stage.stageHeight ;
        }
    }
}