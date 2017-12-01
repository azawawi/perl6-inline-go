use v6.c;

use lib 'lib';
use Inline::Go;

my $code = '
package main

import ( "C"; "unicode/utf8" )

//export GetCharCount
func GetCharCount( cstr *C.char ) int {
    str := C.GoString( cstr )
    return utf8.RuneCountInString(str)
}

//export GetByteCount
func GetByteCount( cstr *C.char ) int {
    str := C.GoString( cstr )
    return len(str)
}

func main() { }
';

my $go = Inline::Go.new( :code( $code ) );
$go.import-all;

my $str = "\c[WINKING FACE]\c[RELIEVED FACE]";
say "Character count of '$str' is = " ~ $go.GetCharCount($str);
say "Byte count of '$str' is      = " ~ $go.GetByteCount($str);
