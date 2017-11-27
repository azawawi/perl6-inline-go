
use v6.c;

use lib 'lib';

use Inline::Go::Grammar;

# import "fmt"
# 
# func main() { }
# const zero = 0.0';
# { fmt.Println("Hello") }
# func main() {}
my $code = 'package main; import "fmt"; ';
 
# 
# //export Add_Int32
# func Add_Int32(a int, b int) int {
#     return a + b
# }
# 
# //export Hello
# func Hello() {
#     fmt.Println("Hello from Go!")
# }
# 
# func main() {
# }

my $match = Inline::Go::Grammar.parse( $code );
say $match;
