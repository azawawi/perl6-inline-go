# Inline::Go

 [![Build Status](https://travis-ci.org/azawawi/perl6-inline-go.svg?branch=master)](https://travis-ci.org/azawawi/perl6-inline-go) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-inline-go?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-inline-go/branch/master)
 

Use inline [Go](https://golang.org/) code within your Perl 6 source code. The
project has the following ambitious goals to achieve:

- Parse Go code using Perl 6 grammars with test suite taking directly from Go
  language specification.
- Transform Go functions and classes to be usable within Perl 6.
- Provide a simple and robust way to take advantage of Go groutines in Perl 6.

**Note:** This currently a totally **experimental** module. Please do not use on
a production system.

The current code base is using simple regexes to find go functions with simple
Go to Perl 6 type mapping. The Perl 6 NativeCall Go function wrapper is add via
an evil `EVAL` in the current package (i.e. Inline::Go) so it can be added only
once.

## Example

```Perl6
use v6.c;

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

my $go = Inline::Go.new( :code( $code ) );
$go.import-all;
$go.Hello;
say $go.Add_Int32(1, 2);
```

For more examples, please see the [examples](examples) folder.

## Installation

- Please install the Go language toolchain from [here](https://golang.org/dl/). You
need at least Go 1.5 or later.

- Install it using zef (a module management tool bundled with Rakudo Star):

```
$ zef install Inline::Go
```

## Testing

- To run tests:
```
$ prove -ve "perl6 -Ilib"
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## See Also

- [Calling Go Functions from Other Languages](https://medium.com/learning-the-go-programming-language/calling-go-functions-from-other-languages-4c7d8bcc69bf).
- [The Go Programming Language Specification ](https://golang.org/ref/spec)

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
