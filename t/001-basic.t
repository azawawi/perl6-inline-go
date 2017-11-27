

use v6.c;
use Test;

use Inline::Go;

plan 2;

my $code = '
package main

import "C"

//export Add_Int32
func Add_Int32(a int, b int) int {
    return a + b
}

func main() {
}
';

my $go = Inline::Go.new( :code( $code ) );
$go.import-all;

ok $go.Add_Int32( 1, 2) == 3, "Add_Int32( 1, 2) works";
ok $go.Add_Int32(-1, 1) == 0, "Add_Int32(-1, 1) works";
