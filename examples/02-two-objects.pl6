use v6.c;

use lib 'lib';
use Inline::Go;

my $code1 = '
package main

import ("C"; "fmt")

//export Hello
func Hello() { fmt.Println("Hello from object #1!") }

func main() { }
';

my $code2 = '
package main

import ("C"; "fmt")

//export Hello
func Hello() { fmt.Println("Hello from object #2!") }

func main() { }
';

# The function is imported into the object not the class
my $o1 = Inline::Go.new( :code( $code1 ) );
$o1.import-all;

my $o2 = Inline::Go.new( :code( $code2 ) );
$o2.import-all;

$o1.Hello;
$o2.Hello;
$o1.Hello;
