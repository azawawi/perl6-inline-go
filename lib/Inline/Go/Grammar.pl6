
use v6.c;

# Reference:
# https://golang.org/ref/spec
#
unit grammar Inline::Go::Grammar;

# SourceFile = PackageClause ";" { ImportDecl ";" } { TopLevelDecl ";" } .
token TOP { <PackageClause> ';' }

# PackageClause  = "package" PackageName .
# PackageName    = identifier .
rule PackageClause { "package" <PackageName> }
rule PackageName   { <identifier> }

# identifier = letter { letter | unicode_digit } .
token identifier { \w+ }
