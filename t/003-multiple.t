use v6.c;

use Test;

plan 3;

if $*KERNEL.name eq 'darwin' {
    # Crash: `runtime/cgo: could not obtain pthread_keys' on darwin/amd64
    # Please see https://gist.github.com/hnakamur/56fa250ca8705b25ee11
    skip-rest "macOS will always fail on this one";
    exit;
}

use Inline::Go;

my $code1 = '
package main

import "C"

//export GetId
func GetId() int { return 1 }

func main() { }
';

my $code2 = '
package main

import "C"

//export GetId
func GetId() int { return 2 }

func main() { }
';

my $o1 = Inline::Go.new( :code( $code1 ) );
$o1.import-all;

my $o2 = Inline::Go.new( :code( $code2 ) );
$o2.import-all;

# The same function name can be imported into different object
# Since it now imported into the object but not the class
ok $o1.GetId == 1, "Correct 1st object return result";
ok $o2.GetId == 2, "Correct 2nd object return result";
ok $o1.GetId != $o2.GetId, "Do not match";
