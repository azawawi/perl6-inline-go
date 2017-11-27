
use v6.c;
use File::Temp;
use NativeCall;

unit class Inline::Go;

has $.code;

#TODO use temp directory
#our ($so-file-name, $so-file-handle) = tempfile( :suffix('.so') );
our $so-file-name = './foo.so';

method import-all {
    # Create a temporary go source file
    my ($go-file-name, $go-file-handle) = tempfile( :suffix('.go') );

    # Write provided go code into temporay file
    $go-file-handle.spurt($!code);

    # Build shared C library from go code
    my $output = qq:x/go build -o $so-file-name -buildmode=c-shared $go-file-name/;
    
    #TODO delete generated files from buildmode=c-shared

    self.parse-go-functions-and-import-them;
}

method find-exported-go-functions {
    my @exports = $!code.match( / '//export' \s+ (\w+) /, :global );
    my %results;
    for @exports {
        #say "Found exported go function: " ~ $_[0];
        my $func-name = ~$_[0];
        %results{$func-name} = $func-name => 1;
    }
    %results;
}

method find-go-parameters(Str:D $signature) {
    #say "Parsing signature: '$signature'";
    my @parameters = $signature.split(",");
    my $results    = gather {
        for @parameters {
            #TODO support all go types
            my $parameter = $_.trim;
            if $parameter ~~ / (\w+) \s+ (int|float64)?/ {
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
    my @functions = $!code.match( /'func' \s+ (\w+) \s* '(' (.*?) ')' \s+ (\w+)? /, :global);
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
            #say "Found go function: " ~ $function-name;
        }
    };
    $results;
}

# Import a specific function
method import(Str:D $func-name) {
    # Check whether it is exportable
    my %exports   = self.find-exported-go-functions;
    die "Function'$func-name' is not exported. Please add cgo's '//export $func-name' comment before your go function declaration." unless %exports{$func-name}.defined;

    # Import function
    my $functions = self.find-go-functions;
    my $imported = False;
    for @$functions {
        next if $func-name ne $_<name>.trim;
        $imported = self._import_function($_).defined ?? True !! False;
    }
    die "Failed to import '$func-name'" unless $imported;
}

method _import_function($function) {
    my %exports   = self.find-exported-go-functions;
    #TODO support more 'Go' to 'Perl 6' type mapping
    my %go-to-p6-type-map =
        "int"     => "int32",
        "float64" => "num64";

    my $func-name = $function<name>.trim;
    # Make sure function is exportable
    return unless %exports{$func-name}.defined;

    my $parameters  = $function<parameters>;
    my $return-type = $function<return-type>.defined
        ?? %go-to-p6-type-map{$function<return-type>}
        !! $function<return-type>;
    #say "Processing $func-name";
    #say "Parameters: $( @$parameters.perl )";
    my $signature   = @$parameters.map({
        my $name = $_<name>;
        my $type = $_<type>;
        # #TODO handle any type
        # #TODO handle implicit type
        my $p6-type = '';
        if $type.defined {
            $p6-type = %go-to-p6-type-map{$type};
        }
        else {
            warn "No type defined for '$name'";
        }
        "$p6-type \$$name";
    }).join(", ");
    my $params = @$parameters.map({
        my $name = $_<name>;
        "\$$name";
    }).join(", ");

    my $ret-decl = $return-type.defined ?? "returns $return-type" !! '';
    #say $ret-decl;
    use MONKEY-SEE-NO-EVAL;
    my $func-decl = "
        method $func-name ( $signature ) \{
            my sub _$func-name\( $signature )
                $ret-decl
                is symbol( '$func-name' )
                is native( '$so-file-name' )
                \{ * \};

            _$func-name\( $params \);
        \}
    ";
    # say $func-decl;
    my $func = EVAL $func-decl;
    say "function definition: '$( $func.perl )'";
    no MONKEY-SEE-NO-EVAL;

    return $func;
}

method parse-go-functions-and-import-them {
    my %exports   = self.find-exported-go-functions;
    my $functions = self.find-go-functions;
    #say "functions: " ~ @functions.perl;
    for @$functions {
        self._import_function($_)
    }

}
