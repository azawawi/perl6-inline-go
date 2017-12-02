use v6.c;
use Test;

plan 19;

use Inline::Go;

my $code = '
package main

import ("C"; "unicode/utf8")

//export Add_Int8
func Add_Int8(a int8, b int8) int8 {
    return a + b;
}

//export Add_UInt8
func Add_UInt8(a uint8, b uint8) uint8 {
    return a + b;
}

//export Add_Int16
func Add_Int16(a int16, b int16) int16 {
    return a + b;
}

//export Add_UInt16
func Add_UInt16(a uint16, b uint16) uint16 {
    return a + b;
}

//export Add_Int32
func Add_Int32(a int32, b int32) int32 {
    return a + b
}

//export Add_UInt32
func Add_UInt32(a uint32, b uint32) uint32 {
    return a + b
}

//export Add_Int64
func Add_Int64(a int64, b int64) int64 {
    return a + b
}

//export Add_UInt64
func Add_UInt64(a uint64, b uint64) uint64 {
    return a + b
}

//export Add_Float32
func Add_Float32(a float32, b float32) float32 {
    return a + b
}

//export Add_Float64
func Add_Float64(a float64, b float64) float64 {
    return a + b
}

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

ok $go.Add_Int8( 1, 2) == 3, "Add_Int8( 1, 2) works";
ok $go.Add_Int8(-1, 1) == 0, "Add_Int8(-1, 1) works";

ok $go.Add_UInt8(1, 2) == 3, "Add_UInt8( 1, 2) works";

ok $go.Add_Int16( 1, 2) == 3, "Add_Int16( 1, 2) works";
ok $go.Add_Int16(-1, 1) == 0, "Add_Int16(-1, 1) works";

ok $go.Add_UInt16(1, 2) == 3, "Add_UInt16( 1, 2) works";

ok $go.Add_Int32( 1, 2) == 3, "Add_Int32( 1, 2) works";
ok $go.Add_Int32(-1, 1) == 0, "Add_Int32(-1, 1) works";

ok $go.Add_UInt32(1, 2) == 3, "Add_UInt32( 1, 2) works";

ok $go.Add_Int64( 1, 2) == 3, "Add_Int64( 1, 2) works";
ok $go.Add_Int64(-1, 1) == 0, "Add_Int64(-1, 1) works";

ok $go.Add_UInt64(1, 2) == 3, "Add_UInt64( 1, 2) works";

ok $go.Add_Float32(1.1.Num, 1.4.Num) == 2.5, "Add_Float32(1.1, 1.4) works";
ok $go.Add_Float32( -1.Num,   1.Num) ==   0, "Add_Float32(-1, 1) works";

ok $go.Add_Float64(1.1.Num, 1.4.Num) == 2.5, "Add_Float64(1.1, 1.4) works";
ok $go.Add_Float64( -1.Num,   1.Num) ==   0, "Add_Float64(-1, 1) works";

my $str = "\c[WINKING FACE]\c[RELIEVED FACE]";
ok $go.GetCharCount($str) == $str.chars,        "Character count of '$str'";
ok $go.GetByteCount($str) == $str.encode.bytes, "Byte count of '$str'";

my $s1 = 'Hello ';
my $s2 = "World \c[WINKING FACE]";
ok $go.AddString( $s1, $s2 ) eq ($s1 ~ $s2), "String addition/return works";
