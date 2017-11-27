
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
rule TOP { <PackageClause> (';')? (<ImportDecl> ';'?)* ( <TopLevelDecl> ';'? )* }

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
rule ConstDecl      { "const" ( <ConstSpec> | "(" ( <ConstSpec> ';'? )* ")" ) }
rule ConstSpec      { <IdentifierList> ( <Type>? "=" <ExpressionList> )?      }

rule IdentifierList { <identifier> ( "," <identifier> )* }
rule ExpressionList { <Expression> ( "," <Expression> )* }

# Expression = UnaryExpr | Expression binary_op Expression .
# UnaryExpr  = PrimaryExpr | unary_op UnaryExpr .
# 
# binary_op  = "||" | "&&" | rel_op | add_op | mul_op .
# rel_op     = "==" | "!=" | "<" | "<=" | ">" | ">=" .
# add_op     = "+" | "-" | "|" | "^" .
# mul_op     = "*" | "/" | "%" | "<<" | ">>" | "&" | "&^" .
# 
# unary_op   = "+" | "-" | "!" | "^" | "*" | "&" | "<-" .
rule Expression { <UnaryExpr> | <Expression> <binary_op> <Expression> }
rule UnaryExpr  { <PrimaryExpr> | <unary_op> <UnaryExpr> }

rule binary_op  { "||" | "&&" | <rel_op> | <add_op> | <mul_op> }
rule rel_op     { "==" | "!=" | "<" | "<=" | ">" | ">="        }
rule add_op     { "+" | "-" | "|" | "^"                        }
rule mul_op     { "*" | "/" | "%" | "<<" | ">>" | "&" | "&^"   }
rule unary_op   { "+" | "-" | "!" | "^" | "*" | "&" | "<-"     }

# PrimaryExpr =
#   Operand |
#   Conversion |
#   PrimaryExpr Selector |
#   PrimaryExpr Index |
#   PrimaryExpr Slice |
#   PrimaryExpr TypeAssertion |
#   PrimaryExpr Arguments .
#
# Selector       = "." identifier .
# Index          = "[" Expression "]" .
# Slice          = "[" [ Expression ] ":" [ Expression ] "]" |
#                  "[" [ Expression ] ":" Expression ":" Expression "]" .
# TypeAssertion  = "." "(" Type ")" .
# Arguments      = "(" [ ( ExpressionList | Type [ "," ExpressionList ] ) [ "..." ] [ "," ] ] ")" .
rule PrimaryExpr {
    <Operand> |
    <Conversion> |
    <PrimaryExpr> <Selector> |
    <PrimaryExpr> <Index> |
    <PrimaryExpr> <Slice> |
    <PrimaryExpr> <TypeAssertion> |
    <PrimaryExpr> <Arguments> }

rule Selector       { "." <identifier> }
rule Index          { "[" <Expression> "]" }
rule Slice          { "[" <Expression>? ":" <Expression>? "]" |
                      "[" <Expression>? ":" <Expression> ":" <Expression> "]" }
rule TypeAssertion  { "." "(" <Type> ")" }
rule Arguments      { "(" ( ( <ExpressionList> | <Type> ( "," <ExpressionList> )? ) "..."? ","? )? ")" }

# Operand     = Literal | OperandName | MethodExpr | "(" Expression ")" .
# Literal     = BasicLit | CompositeLit | FunctionLit .
# BasicLit    = int_lit | float_lit | imaginary_lit | rune_lit | string_lit .
# OperandName = identifier | QualifiedIdent.
rule Operand     { <Literal> | <OperandName> | <MethodExpr> | "(" <Expression> ")"       }
rule Literal     { <BasicLit> | <CompositeLit> | <FunctionLit>                           }
rule BasicLit    { <int_lit> | <float_lit> | <imaginary_lit> | <rune_lit> | <string_lit> }
rule OperandName { <identifier> | <QualifiedIdent>                                       }

# int_lit     = decimal_lit | octal_lit | hex_lit .
# decimal_lit = ( "1" … "9" ) { decimal_digit } .
# octal_lit   = "0" { octal_digit } .
# hex_lit     = "0" ( "x" | "X" ) hex_digit { hex_digit } .
rule int_lit     { <decimal_lit> | <octal_lit> | <hex_lit> }
rule decimal_lit { ( "1" ... "9" ) <decimal_digit>* }
token octal_lit  { "0" <octal_digit>* }
token hex_lit    { "0" ( "x" | "X" ) <hex_digit> <hex_digit>* }

# float_lit = decimals "." [ decimals ] [ exponent ] |
#             decimals exponent |
#             "." decimals [ exponent ] .
# decimals  = decimal_digit { decimal_digit } .
# exponent  = ( "e" | "E" ) [ "+" | "-" ] decimals .
token float_lit { <decimals> "." <decimals>? <exponent>? |
                  <decimals> <exponent> |
                  "." <decimals> <exponent>? }
token decimals  { <decimal_digit> <decimal_digit>* }
token exponent  { ( "e" | "E" ) ( "+" | "-" )? <decimals> }

# imaginary_lit = (decimals | float_lit) "i" .
token imaginary_lit { (<decimals> | <float_lit>) "i" }

# CompositeLit  = LiteralType LiteralValue .
# LiteralType   = StructType | ArrayType | "[" "..." "]" ElementType |
#                 SliceType | MapType | TypeName .
# LiteralValue  = "{" [ ElementList [ "," ] ] "}" .
# ElementList   = KeyedElement { "," KeyedElement } .
# KeyedElement  = [ Key ":" ] Element .
# Key           = FieldName | Expression | LiteralValue .
# FieldName     = identifier .
# Element       = Expression | LiteralValue .
rule CompositeLit  { <LiteralType> <LiteralValue> }
rule LiteralType   { <StructType> | <ArrayType> | "[" "..." "]" <ElementType> |
                     <SliceType> | <MapType> | <TypeName> }
rule LiteralValue  { "{" ( <ElementList> [ "," ] )? "}" }
rule ElementList   { <KeyedElement> ( "," <KeyedElement> )* }
rule KeyedElement  { ( <Key> ":" )? <Element> }
rule Key           { <FieldName> | <Expression> | <LiteralValue> }
rule FieldName     { <identifier> }
rule Element       { <Expression> | <LiteralValue> }

# FunctionLit = "func" Function .
rule FunctionLit { "func" <Function> }

# MethodExpr    = ReceiverType "." MethodName .
# ReceiverType  = TypeName | "(" "*" TypeName ")" | "(" ReceiverType ")" .
rule MethodExpr    { <ReceiverType> "." <MethodName> }
rule ReceiverType  { <TypeName> | "(" "*" <TypeName> ")" | "(" <ReceiverType> ")" }

# Conversion = Type "(" Expression [ "," ] ")" .
rule Conversion { <Type> "(" <Expression> ","? ")" }

# TypeDecl = "type" ( TypeSpec | "(" { TypeSpec ";" } ")" ) .
# TypeSpec = AliasDecl | TypeDef .
rule TypeDecl { "type" ( <TypeSpec> | "(" ( <TypeSpec> ';'? )* ")" ) }
rule TypeSpec { <AliasDecl> | <TypeDef> }

# AliasDecl = identifier "=" Type .
rule AliasDecl { <identifier> "=" <Type> }

# TypeDef = identifier Type .
rule TypeDef { <identifier> <Type> }

# VarDecl = "var" ( VarSpec | "(" { VarSpec ";" } ")" ) .
# VarSpec = IdentifierList ( Type [ "=" ExpressionList ] | "=" ExpressionList ) .
rule VarDecl     { "var" ( <VarSpec> | "(" ( <VarSpec> ';'? )* ")" ) }
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
rule ParameterDecl  { <IdentifierList>? ("...")? <Type>        }

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
rule StructType    { "struct" "{" ( <FieldDecl> ';'? )* "}" }
rule FieldDecl     { (<IdentifierList> <Type> | <EmbeddedField>) <Tag>? }
rule EmbeddedField { "*"? <TypeName> }
rule Tag           { <string_lit> }

# PointerType = "*" BaseType .
# BaseType    = Type .
rule PointerType { "*" <BaseType> }
rule BaseType    { <Type> }

# InterfaceType      = "interface" "{" { MethodSpec ";" } "}" .
# MethodSpec         = MethodName Signature | InterfaceTypeName .
# MethodName         = identifier .
# InterfaceTypeName  = TypeName .
rule InterfaceType      { "interface" "{" ( <MethodSpec> ';'? )* "}" }
rule MethodSpec         { ( <MethodName> <Signature> | <InterfaceTypeName> ) }
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
rule Block         { { say "Block"} '{' <StatementList> '}' }
rule StatementList { { say "StatementList"} ( <Statement> ';'? )*   }

# Statement =
#   Declaration | LabeledStmt | SimpleStmt |
#   GoStmt | ReturnStmt | BreakStmt | ContinueStmt | GotoStmt |
#   FallthroughStmt | Block | IfStmt | SwitchStmt | SelectStmt | ForStmt |
#   DeferStmt .
#
# SimpleStmt = EmptyStmt | ExpressionStmt | SendStmt | IncDecStmt | Assignment | ShortVarDecl .
rule Statement {
    { say "Statement"}
    <Declaration> | <LabeledStmt> | <SimpleStmt> |
    <GoStmt> | <ReturnStmt> | <BreakStmt> | <ContinueStmt> | <GotoStmt> |
    <FallthroughStmt> | <Block> | <IfStmt> | <SwitchStmt> | <SelectStmt> |
    <ForStmt> | <DeferStmt>
}

rule SimpleStmt {
    { say "SimpleStmt"}
    # <EmptyStmt>? |
    <ExpressionStmt> | <SendStmt> | <IncDecStmt> |  <Assignment> |
    <ShortVarDecl>
}

# LabeledStmt = Label ":" Statement .
# Label       = identifier .
rule LabeledStmt { <Label> ":" <Statement> }
rule Label       { <identifier> }

# EmptyStmt = .
#rule EmptyStmt { { say "EmptyStmt"} '' }

# ExpressionStmt = Expression .
rule ExpressionStmt { <Expression> }

# SendStmt = Channel "<-" Expression .
# Channel  = Expression .
rule SendStmt { <Channel> "<-" <Expression> }
rule Channel  { <Expression> }

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

# newline        = /* the Unicode code point U+000A */ .
# unicode_char   = /* an arbitrary Unicode code point except newline */ .
# unicode_letter = /* a Unicode code point classified as "Letter" */ .
# unicode_digit  = /* a Unicode code point classified as "Number, decimal digit" */ .
token newline        { \n }
token unicode_char   { <alpha> }
token unicode_letter { <alpha> }
token unicode_digit  { <digit> }

# letter        = unicode_letter | "_" .
# decimal_digit = "0" … "9" .
# octal_digit   = "0" … "7" .
# hex_digit     = "0" … "9" | "A" … "F" | "a" … "f" .
token letter        { <unicode_letter> | "_" }
token decimal_digit { <[0..9]> }
token octal_digit   { <[0..7]> }
token hex_digit     { <[0..9]> | <[A..F]> | <[a..f]> }

# identifier = letter { letter | unicode_digit } .
token identifier { <alpha> <alnum>* }
