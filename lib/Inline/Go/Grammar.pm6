
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
token TOP { <PackageClause> ';'? (<ImportDecl> ';'?)* ( <TopLevelDecl> ";"? )* }

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

# Declaration   = ConstDecl | TypeDecl | VarDecl .
# TopLevelDecl  = Declaration | FunctionDecl | MethodDecl .
rule Declaration  { <ConstDecl> | <TypeDecl> | <VarDecl> }
rule TopLevelDecl { <Declaration> | <FunctionDecl> | <MethodDecl> }

# ConstDecl      = "const" ( ConstSpec | "(" { ConstSpec ";" } ")" ) .
# ConstSpec      = IdentifierList [ [ Type ] "=" ExpressionList ] .
#
# IdentifierList = identifier { "," identifier } .
# ExpressionList = Expression { "," Expression } .
rule ConstDecl      { "const" ( <ConstSpec> | "(" ( <ConstSpec> ";"? )* ")" ) }
rule ConstSpec      { <IdentifierList> ( <Type>? "=" <ExpressionList> )?      }

rule IdentifierList { <identifier> ( "," <identifier> )* }
rule ExpressionList { <Expression> ( "," <Expression> )* }

# TypeDecl = "type" ( TypeSpec | "(" { TypeSpec ";" } ")" ) .
# TypeSpec = AliasDecl | TypeDef .
rule TypeDecl { "type" ( <TypeSpec> | "(" ( <TypeSpec> ";"? )* ")" ) }
rule TypeSpec { <AliasDecl> | <TypeDef> }

# AliasDecl = identifier "=" Type .
rule AliasDecl { <identifier> "=" <Type> }

# TypeDef = identifier Type .
rule TypeDef { <identifier> <Type> }

# VarDecl = "var" ( VarSpec | "(" { VarSpec ";" } ")" ) .
# VarSpec = IdentifierList ( Type [ "=" ExpressionList ] | "=" ExpressionList ) .
rule VarDecl     { "var" ( <VarSpec> | "(" ( <VarSpec> ";"? )* ")" ) }
rule VarSpec     { <IdentifierList> ( <Type> [ "=" <ExpressionList> ] | "=" <ExpressionList> ) }

# FunctionDecl = "func" FunctionName ( Function | Signature ) .
# FunctionName = identifier .
# Function     = Signature FunctionBody .
# FunctionBody = Block .
rule FunctionDecl { "func" <FunctionName> ( <Function> | <Signature> ) }
rule FunctionName { <identifier> }
rule Function     { <Signature> <FunctionBody> }
rule FunctionBody { <Block> }

# MethodDecl = "func" Receiver MethodName ( Function | Signature ) .
# Receiver   = Parameters .
rule MethodDecl { "func" <Receiver> <MethodName> ( <Function> | <Signature> ) }
rule Receiver   { <Parameters> }

# FunctionType   = "func" Signature .
# Signature      = Parameters [ Result ] .
# Result         = Parameters | Type .
# Parameters     = "(" [ ParameterList [ "," ] ] ")" .
# ParameterList  = ParameterDecl { "," ParameterDecl } .
# ParameterDecl  = [ IdentifierList ] [ "..." ] Type .
rule FunctionType   { "func" <Signature>                       }
rule Signature      { <Parameters> <Result>?                   }
rule Result         { <Parameters> | <Type>                    }
rule Parameters     { "(" ( <ParameterList> ","? )? ")"        }
rule ParameterList  { <ParameterDecl> ( "," <ParameterDecl> )* }
rule ParameterDecl  { <IdentifierList>? "..."? <Type>          }

# Type      = TypeName | TypeLit | "(" Type ")" .
# TypeName  = identifier | QualifiedIdent .
# TypeLit   = ArrayType | StructType | PointerType | FunctionType | InterfaceType |
# 	    SliceType | MapType | ChannelType .
rule Type     { <TypeName> | <TypeLit> | "(" <Type> ")" }
rule TypeName { <identifier> | <QualifiedIdent> }
rule TypeLit  { <ArrayType> | <StructType> | <PointerType> | <FunctionType> |
                <InterfaceType> | <SliceType> | <MapType> | <ChannelType> }

# ArrayType   = "[" ArrayLength "]" ElementType .
# ArrayLength = Expression .
# ElementType = Type .
rule ArrayType    { "[" <ArrayLength> "]" <ElementType> }
rule ArrayLength  { <Expression> }
rule ElementType  { <Type> }

# StructType    = "struct" "{" { FieldDecl ";" } "}" .
# FieldDecl     = (IdentifierList Type | EmbeddedField) [ Tag ] .
# EmbeddedField = [ "*" ] TypeName .
# Tag           = string_lit .
rule StructType    { "struct" "{" ( <FieldDecl> ";"? )* "}" }
rule FieldDecl     { (<IdentifierList> <Type> | <EmbeddedField>) <Tag>? }
rule EmbeddedField { [ "*" ] <TypeName> }
rule Tag           { <string_lit> }

# PointerType = "*" BaseType .
# BaseType    = Type .
rule PointerType { "*" <BaseType> }
rule BaseType    { <Type> }

# InterfaceType      = "interface" "{" { MethodSpec ";" } "}" .
# MethodSpec         = MethodName Signature | InterfaceTypeName .
# MethodName         = identifier .
# InterfaceTypeName  = TypeName .
rule InterfaceType      { "interface" "{" ( <MethodSpec> ";"? )* "}" }
rule MethodSpec         { <MethodName> <Signature> | <InterfaceTypeName> }
rule MethodName         { <identifier> }
rule InterfaceTypeName  { <TypeName> }

# SliceType = "[" "]" ElementType .
rule SliceType { "[" "]" <ElementType> }

# MapType     = "map" "[" KeyType "]" ElementType .
# KeyType     = Type .
rule MapType { "map" "[" <KeyType> "]" <ElementType> }
rule KeyType { <Type> }

# ChannelType = ( "chan" | "chan" "<-" | "<-" "chan" ) ElementType .
rule ChannelType { ( "chan" | "chan" "<-" | "<-" "chan" ) <ElementType> }

# QualifiedIdent = PackageName "." identifier .
rule QualifiedIdent { <PackageName> "." <identifier> }

# Block = "{" StatementList "}" .
# StatementList = { Statement ";" } .
rule Block         { "{" <StatementList> "}" }
rule StatementList { ( <Statement> ";"? )*   }

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
