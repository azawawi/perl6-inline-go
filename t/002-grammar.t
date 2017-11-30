
use v6.c;
use Test;

my @samples =
    qq{package main;},
    qq{package main\n},
    qq{package main; import "fmt"},
    qq{package main\nimport "fmt"},
    qq{package main; import "fmt"; import "math"},
    qq{package main\nimport "fmt"\nimport "math"},
    qq{package main;\nimport("fmt";"math")},
    qq{package main;\nimport("fmt"\n"math")},
    qq{package main; import "fmt"; import "math"; func main()},
    qq{package main\nimport "fmt"\nimport "math"\nfunc main()},
    ;

plan @samples.elems;

use Inline::Go::Grammar;

for @samples -> $sample {
    my $rule  = 'TOP';
    my $match = Inline::Go::Grammar.parse( $sample, :rule($rule) );
    ok $match.defined, "$($sample.perl) matches '$rule'";
}
