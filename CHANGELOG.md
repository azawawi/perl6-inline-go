# Change Log for `Inline::Go`

## 0.0.5 - **UNDER DEVELOPMENT**
    - ...

## 0.0.4 - 2 Dec 2017
    - Add support for Go C Strings (with tests).
    - Skip `003-multiple.t` on macOS since Go runtime always crashes on it.

## 0.0.3 - 1 Dec 2017
    - Add change log.
    - Use roles to add methods to objects instead of classes.
    - Refactor a bit for speed.
    - Refactor grammar to handle Go's semicolons end-of-line rule.
    - Add grammar and multiple object tests.

## 0.0.2 - 29 Nov 2017
    - Add Windows support using `gcc`.
    - Add experimental `Inline::Go::Grammar`.
    - Add missing dependency on `File::Temp`.
    - Add initial examples.
    - Add more Go type to Perl 6 NativeCall mapping.
    - Use proper temporary directory go/gcc build operations.
    - Add `:debug` boolean attribute.
    - Add more tests.
    - Remove debugging code.

## 0.0.1 - 27 Nov 2017
    - Initial Release. An idea is born.
