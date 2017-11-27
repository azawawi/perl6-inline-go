
use v6.c;

#
# Reference:
# The Go Programming Language Specification 
# https://golang.org/ref/spec
#

# Legend:
# |   alternation
# ()  grouping
# []  option (0 or 1 times)
# {}  repetition (0 to n times)

unit grammar Inline::Go::Grammar;

# SourceFile = PackageClause ";" { ImportDecl ";" } { TopLevelDecl ";" } .
token TOP { <PackageClause> ';'? (<ImportDecl> ';'?)* }

# PackageClause  = "package" PackageName .
# PackageName    = identifier .
rule PackageClause { "package" <PackageName> }
rule PackageName   { <identifier> }

# ImportDecl = "import" ( ImportSpec | "(" { ImportSpec ";" } ")" ) .
# ImportSpec = [ "." | PackageName ] ImportPath .
# ImportPath = string_lit .
rule ImportDecl { "import" ( <ImportSpec> | '(' ( <ImportSpec> ';'? )* ')' ) }
rule ImportSpec { ( '.' | <PackageName> )? <ImportPath> }
rule ImportPath { <string_lit> }

# string_lit             = raw_string_lit | interpreted_string_lit .
# raw_string_lit         = "`" { unicode_char | newline } "`" .
# interpreted_string_lit = `"` { unicode_value | byte_value } `"` .
rule string_lit              { <raw_string_lit> | <interpreted_string_lit> }
token raw_string_lit         { '`' ( <unicode_char>  | <newline>    )* '`' }
token interpreted_string_lit { '"' ( <unicode_value> | <byte_value> )* '"' }

# rune_lit         = "'" ( unicode_value | byte_value ) "'" .
# unicode_value    = unicode_char | little_u_value | big_u_value | escaped_char .
# byte_value       = octal_byte_value | hex_byte_value .
# octal_byte_value = `\` octal_digit octal_digit octal_digit .
# hex_byte_value   = `\` "x" hex_digit hex_digit .
# little_u_value   = `\` "u" hex_digit hex_digit hex_digit hex_digit .
# big_u_value      = `\` "U" hex_digit hex_digit hex_digit hex_digit
#                            hex_digit hex_digit hex_digit hex_digit .
# escaped_char     = `\` ( "a" | "b" | "f" | "n" | "r" | "t" | "v" | `\` | "'" | `"` ) .
token rune_lit         { "'" ( <unicode_value> | <byte_value> ) "'" }
token unicode_value    { <unicode_char> | <little_u_value> | <big_u_value> | <escaped_char> }
token byte_value       { <octal_byte_value> | <hex_byte_value> }
token octal_byte_value { '\\' <octal_digit> <octal_digit> <octal_digit> }
token hex_byte_value   { '\\' "x" <hex_digit> <hex_digit> }
token little_u_value   { '\\' "u" <hex_digit> <hex_digit> <hex_digit> <hex_digit> }
token big_u_value      { '\\' "U" <hex_digit> <hex_digit> <hex_digit> <hex_digit>
                                  <hex_digit> <hex_digit> <hex_digit> <hex_digit> }
token escaped_char     { '\\' ( "a" | "b" | "f" | "n" | "r" | "t" | "v" | '\\' | "'" | '"' ) }

# unicode_char   = /* an arbitrary Unicode code point except newline */ .
# unicode_letter = /* a Unicode code point classified as "Letter" */ .
# unicode_digit  = /* a Unicode code point classified as "Number, decimal digit" */ .
token unicode_char   { \w }
token unicode_letter { \w }
token unicode_digit  { \w }

# identifier = letter { letter | unicode_digit } .
token identifier { \w+ }
