use v6.c;

use lib 'lib';
use Inline::Go;

my $code = '
package main

import ( "C"; "unicode/utf8" )

//export GetCharCount
func GetCharCount( cstr *C.char ) int {
    return utf8.RuneCountInString( C.GoString( cstr ) )
}

//export GetByteCount
func GetByteCount( cstr *C.char ) int {
    return len( C.GoString( cstr ) )
}

//export AddString
func AddString( cstr1 *C.char, cstr2 *C.char ) *C.char {
    return C.CString( C.GoString( cstr1 ) + C.GoString( cstr2 ) )
}

func main() { }
';

my $go = Inline::Go.new( :code( $code ) );
$go.import-all;

my $str = "\c[WINKING FACE]\c[RELIEVED FACE]";
say "Character count of '$str' is = " ~ $go.GetCharCount($str);
say "Byte count of '$str' is      = " ~ $go.GetByteCount($str);

my $s1 = 'Hello ';
my $s2 = "World \c[WINKING FACE]";
printf( "'%s' + '%s' = '%s'\n", $s1, $s2, $go.AddString( $s1, $s2 ) );
