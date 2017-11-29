
use v6.c;
use Test;

plan 5;

use Inline::Go::Grammar;

# Test package
{
    my $rule  = 'TOP';
    my $code  = 'package main';
    my $match = Inline::Go::Grammar.parse( $code, :rule($rule) );
    ok $match.defined, "'$code' matches '$rule'";
    $code  = 'package m';
    $match = Inline::Go::Grammar.parse( $code, :rule($rule) );
    ok $match.defined, "'$code' matches '$rule'";
}

{
    # Test package with single/multiple imports
    my $rule  = 'TOP';
    my $code  = 'package main import "fmt"';
    my $match = Inline::Go::Grammar.parse( $code );
    ok $match.defined, "'$code' matches '$rule'";

    $code  = 'package main import "fmt" import "math"';
    $match = Inline::Go::Grammar.parse( $code, :rule($rule));
    ok $match.defined, "'$code' matches '$rule'";

    $code  = 'package main import ("fmt"; "math")';
    $match = Inline::Go::Grammar.parse( $code, :rule($rule));
    ok $match.defined, "'$code' matches '$rule'";

    #TODO test semicolons
}
