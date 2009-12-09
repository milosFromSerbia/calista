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

package calista.utils
{
    /**
     * Encode and decode between multi-byte Unicode characters and UTF-8 multiple single-byte character encoding.
     */
    public class UTF8 
    {
        /**
         * Encodes multi-byte Unicode string into utf-8 multiple single-byte characters (BMP / basic multilingual plane only). 
         * Chars in range U+0080 - U+07FF are encoded in 2 chars, U+0800 - U+FFFF in 3 chars
         * @param uni The Unicode string to be encoded as UTF-8.
         * @returns The encoded string.
         */
        public static function encode( uni:String ):String 
        {
            var utf:String = uni.replace
            (
                _reg1 ,
                function(c:String):String
                { 
                    var cc:Number = c.charCodeAt(0);
                    return String.fromCharCode(0xc0 | cc>>6, 0x80 | cc&0x3f); 
                }
            ) ;
            utf = utf.replace
            (
                _reg2 ,
                function( c:String ):String
                { 
                    var cc:Number = c.charCodeAt(0); 
                    return String.fromCharCode(0xe0 | cc>>12, 0x80 | cc>>6&0x3F, 0x80 | cc&0x3f); 
                }
            );
            return utf ;
        }
        
        /**
         * Decode utf-8 encoded string back into multi-byte Unicode characters.
         * @param utf UTF-8 string to be decoded back to Unicode
         * @returns The decoded string.
         */
        public static function decode( utf:String ):String 
        {
            var uni:String = utf.replace
            (
                _reg3 ,
                function(c:String):String
                { 
                    var cc:Number = ( c.charCodeAt(0) & 0x1F ) << 6 | c.charCodeAt(1) & 0x3F ;
                    return String.fromCharCode( cc ) ; 
                }
            ) ;
            uni = uni.replace
            (
                _reg4 ,
                function( c:String ):String
                { 
                    var cc:Number = ( ( c.charCodeAt(0) & 0x0F ) <<12 ) | ( ( c.charCodeAt(1) & 0x3F ) << 6 ) | ( c.charCodeAt(2) & 0x3F ) ; 
                    return String.fromCharCode( cc ); 
                }
            ) ;
            return uni ;
        }
        
        /**
         * U+0080 - U+07FF => 2 bytes 110yyyyy, 10zzzzzz
         * @private
         */
        private static const _reg1:RegExp = /[\u0080-\u07FF]/g ;
        
        /**
         * U+0800 - U+FFFF => 3 bytes 1110xxxx, 10yyyyyy, 10zzzzzz
         * @private
         */
        private static const _reg2:RegExp = /[\u0800-\uFFFF]/g ;
        
        /**
         * 2-byte chars
         * @private
         */
        private static const _reg3:RegExp = /[\u00c0-\u00df][\u0080-\u00bf]/g ;
        
        /**
         * 3-byte chars
         * @private
         */
        private static const _reg4:RegExp = /[\u00e0-\u00ef][\u0080-\u00bf][\u0080-\u00bf]/g ;
    }
}