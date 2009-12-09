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
     * The enumeration of all tags used to serialize the zip files.
     */
    public class ZipTag
    {
        /////////// The local file header
        
        /**
         * The LOC signature (PK\003\004).
         */
        public static const LOCSIG:uint = 0x04034b50 ;
        
        /**
         * The LOC header size.
         */
        public static const LOCHDR:uint = 30 ;
        
        /**
         * The LOC version needed to extract.
         */
        public static const LOCVER:uint = 4 ; 
        
        /**
         * The LOC filename length.
         */
        public static const LOCNAM:uint = 26 ;
        
        /////////// The Data descriptor
        
        /**
         * The EXT signature (PK\007\008).
         */
        public static const EXTSIG:uint = 0x08074b50 ; 
        
        /**
         * The EXT header size.
         */
        public static const EXTHDR:uint = 16 ; 
        
        /////////// The central directory file header
        
        /**
         * The CEN signature (PK\001\002).
         */
        public static const CENSIG:uint = 0x02014b50 ; 
        
        /**
         * The CEN header size.
         */
        public static const CENHDR:uint = 46 ; 
        
        /**
         * The CEN version needed to extract.
         */
        public static const CENVER:uint = 6 ;
        
        /**
         * The CEN filename length.
         */
        public static const CENNAM:uint = 28 ; 
        
        /**
         * The CEN offset.
         */
        public static const CENOFF:uint = 42 ;
        
        /////////// The entries in the end of central directory
        
        /**
         * The END signature (PK\005\006).
         */
        public static const ENDSIG:uint = 0x06054b50 ; 
        
        /**
         * The END header size.
         */
        public static const ENDHDR:uint = 22 ; 
        
        /**
         * The END total number of entries.
         */
        public static const ENDTOT:uint = 10 ;
        
        /**
         * The END offset.
         */
        public static const ENDOFF:uint = 16 ;
    }
}
