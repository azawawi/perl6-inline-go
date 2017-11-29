use v6.c;

use lib 'lib';
use Inline::Go;

my $code = '
package main

import "C"
import "fmt"

//export Add_Int32
func Add_Int32(a int, b int) int {
    return a + b
}

//export Add_Float32
func Add_Float32(a float32, b float32) float32 {
    return a + b
}

//export Hello
func Hello() {
    fmt.Println("Hello from Go!")
}

func main() {
}
';

my $go = Inline::Go.new( :code( $code ) );
$go.import-all;
$go.Hello;
say $go.Add_Int32(1, 2);
say $go.Add_Float32(1.1.Num, 1.4.Num);
