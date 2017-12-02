
use v6.c;
use File::Temp;
use NativeCall;

unit class Inline::Go;

# Debug switch
has $.debug;

# The Go code that needs to be inlined
has $.code;

# Temporary shard library file name
has $!so-file-name;

# Temporary directory
has $!temp-dir;

# Golang to p6 type mapping
my %go-to-p6-type-map =
    "bool"    => "Bool",
    "uint8"   => "uint8",
    "uint16"  => "uint16",
    "uint32"  => "uint32",
    "uint64"  => "uint64",
    "int8"    => "int8",
    "int16"   => "int16",
    "int32"   => "int32",
    "int64"   => "int64",
    "int"     => "int32",
    "rune"    => "int32",
    "float32" => "num32",
    "float64" => "num64",
    "*C.char" => "Str",
    ;
    #TODO C.xyz types also
    #TODO "complex64"
    #TODO "complex128"

method import-all {
    # Create a temporary build directory
    $!temp-dir = tempdir.IO.add( "perl6-inline-go" )
        unless $!temp-dir.defined;
    $!temp-dir.mkdir;
    my $go-file-name = ~$!temp-dir.add( "foo.go" );

    # Write provided go code into temporay file
    $go-file-name.IO.spurt( $!code, :createonly );

    # Build shared C library from go code
    my $output;
    if $*DISTRO.is-win {
        # Windows platform magic
        # <El_Che> azawawi: https://stackoverflow.com/questions/40573401/building-a-dll-with-go-1-7
        # <-- a two step solution?
        $!so-file-name = ~$!temp-dir.add( "foo.dll" )
            unless $!so-file-name.defined;

        # Need to force gcc into linking go runtime
        my %exported = self.find-exported-go-functions;
        die "Please export at least one Go function for windows support to work properly"
            if %exported.elems == 0;
        my $function = %exported.keys[0];
        my $foo_c_workaround = "
#include \"foo.h\"
void onlyNeededToForceGoRuntimeLinkage() \{
    void *ptr = $function;
\}
        ";
        $!temp-dir.add( "foo.c" ).IO.spurt( $foo_c_workaround, :createonly );
        $output = qq:x/cd $!temp-dir && go build -o foo.a -buildmode=c-archive foo.go/;
        $output = qq:x/cd $!temp-dir && gcc -shared -pthread -o foo.dll foo.c foo.a -lWinMM -lntdll -lWS2_32/;
    } else {
        # Linux, macOS platforms
        $!so-file-name = ~$!temp-dir.add( "foo.so" )
            unless $!so-file-name.defined;
        $output = qq:x/go build -o $!so-file-name -buildmode=c-shared $go-file-name/;
    }

    self.parse-go-functions-and-import-them;
}

method find-exported-go-functions {
    my @exports = $!code.match( / '//export' \s+ (\w+) /, :global );
    my %results;
    for @exports {
        my $func-name          = ~$_[0];
        %results{ $func-name } = $func-name => 1;
    }
    %results;
}

method find-go-parameters(Str:D $signature) {
    my @parameters = $signature.split(",");
    my $results    = gather {
        for @parameters {
            my $parameter = $_.trim;
            if $parameter ~~ / (\w+) \s+ (\*? \w+ (\. \w+)? )? / {
                my $parameter-name = $/[0];
                my $parameter-type = $/[1];
                take {
                    name => ~$parameter-name,
                    type => $parameter-type.defined ?? ~$parameter-type !! Nil
                };
            }
        }
    };
}

method find-go-functions {
    my @functions = $!code.match(
        / 'func' \s+ (\w+) \s* '(' (.*?) ')' \s+ (\*? \w+ (\. \w+)? )? /,
        :global
    );
    my $results = gather {
        for @functions {
            my $function-name = ~$_[0];
            my $signature     = ~$_[1];
            my $return-type   = $_[2].defined ?? ~$_[2] !! Nil;
            my $parameters    = self.find-go-parameters($signature);

            take {
                name        => $function-name,
                parameters  => $parameters,
                return-type => $return-type,
            }
        }
    };
    $results;
}

# Import a specific function
method import(Str:D $func-name) {
    # Check whether it is exportable
    my %exports   = self.find-exported-go-functions;
    die "Function'$func-name' is not exported.
Please add cgo's '//export $func-name' comment before your go function
declaration." unless %exports{$func-name}.defined;

    # Import function
    my $functions = self.find-go-functions;
    my $func-decl;
    for @$functions {
        next if $func-name ne $_<name>.trim;
        $func-decl = self._import_function($_).defined ?? True !! False;
    }

    die "Failed to import '$func-name'" unless $func-decl.defined;

    my $role-decl = "
        role GoFunctionWrappers \{
            $func-decl
        \}
    ";
    self._apply-role( $role-decl );

}

method _import_function($function) {
    my %exports   = self.find-exported-go-functions;
    my $func-name = $function<name>.trim;

    # Return if the function is not exportable
    return unless %exports{$func-name}.defined;

    my $parameters  = $function<parameters>;
    my $return-type = $function<return-type>.defined
        ?? %go-to-p6-type-map{$function<return-type>}
        !! $function<return-type>;
    my $signature   = @$parameters.map({
        my $name = $_<name>;
        my $type = $_<type>;
        # #TODO handle any type
        # #TODO handle implicit type
        my $p6-type = '';
        if $type.defined {
            $p6-type = %go-to-p6-type-map{$type};
        } else {
            die "No type defined for '$name'";
        }
        "$p6-type \$$name";
    }).join(", ");
    my $params = @$parameters.map({
        my $name = $_<name>;
        "\$$name";
    }).join(", ");

    my $ret-decl = $return-type.defined ?? "returns $return-type" !! '';

    my $func-decl = "
        method $func-name ( $signature ) \{
            my sub _$func-name\( $signature )
                $ret-decl
                is symbol( '$func-name' )
                is native( '$!so-file-name' )
                \{ * \};

            _$func-name\( $params \)$(
                $return-type.defined && $return-type eq 'Bool' ?? ' == 1' !! ''
            );
        \}
    ";
    say $func-decl if $!debug;

    return $func-decl;
}

method parse-go-functions-and-import-them {
    my %exports   = self.find-exported-go-functions;
    my $functions = self.find-go-functions;
    my @func-decls;
    for @$functions {
        my $func-name = $_<name>;
        next unless %exports{ $func-name }.defined;

        my $func-decl = self._import_function($_);
        die "Failed to import '$func-name'" unless $func-decl.defined;
        @func-decls.append( $func-decl )
    }

    my $role-decl = "
        role GoFunctionWrappers \{
            $( @func-decls.join("\n") )
        \}
    ";
    self._apply-role( $role-decl );

    return;
}

method _apply-role($role-decl) {
    use MONKEY-SEE-NO-EVAL;
    my $role = EVAL $role-decl;
    no MONKEY-SEE-NO-EVAL;
    # Apply the role which adds the methods we need to the current object
    # instead of the class
    self does $role;
}
