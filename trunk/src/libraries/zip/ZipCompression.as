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
    /**
     * The enumeration of all compression method of the zip files.
     */
    public class ZipCompression 
    {
        /**
         * Compression level "none" (0).
         */
        public static const NONE:int = 0 ;
        
        /**
         * Compression level "shrunk" (1).
         */
        public static const SHRUNK:int = 1 ;
        
        /**
         * Compression level "reduced 1" (2).
         */
        public static const REDUCED_1:int = 2 ;
        
        /**
         * Compression level "reduced 2" (3).
         */
        public static const REDUCED_2:int = 3 ;
        
        /**
         * Compression level "reduced 3" (4).
         */
        public static const REDUCED_3:int = 4 ;
        
        /**
         * Compression level "reduced 4" (5).
         */
        public static const REDUCED_4:int = 5 ;
        
        /**
         * Compression level "imploded" (6).
         */
        public static const IMPLODED:int = 6 ;
        
        /**
         * Compression level "tokenized" (7).
         */
        public static const TOKENIZED:int = 7 ;
        
        /**
         * Compression level "deflated" (8).
         */
        public static const DEFLATED:int = 8 ;
        
        /**
         * Compression level "deflated ext" (9).
         */
        public static const DEFLATED_EXT:int = 9 ;
        
        /**
         * Compression level "imploded pkware" (10).
         */
        public static const IMPLODED_PKWARE:int = 10 ;
    }
}
