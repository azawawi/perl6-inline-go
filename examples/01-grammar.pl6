
use v6.c;

use lib 'lib';
use Inline::Go::Grammar;

my $code = '
package main

import "C"
import "fmt"

//export Add_Int32
func Add_Int32(a int, b int) int {
    return a + b
}

//export Hello
func Hello() {
    fmt.Println("Hello from Go!")
}

func main() {
}
';

my $go-grammar = Inline::Go::Grammar.parse( $code );
