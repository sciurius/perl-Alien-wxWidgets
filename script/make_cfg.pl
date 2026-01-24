#! perl

# Generate config for wxWidgets

# Author          : Johan Vromans
# Created On      : Tue Sep 15 15:59:04 1992
# Last Modified By: Johan Vromans
# Last Modified On: Fri Jan 23 14:49:44 2026
# Update Count    : 82
# Status          : Unknown, Use with caution!

################ Common stuff ################

use strict;
use feature 'signatures';
no warnings 'experimental::signatures';

# Package name.
my $my_package = 'Alien::wxWidgets';
# Program name and version.
my ($my_name, $my_version) = qw( make_cfg 0.01 );

################ Command line parameters ################

use Getopt::Long 2.13;

# Command line options.
my $wxdir;
my $wxversion;
my $output;
my $verbose = 1;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test mode.

# Process command line options.
app_options();

# Post-processing.
$trace |= ($debug || $test);

################ Presets ################

################ The Process ################

use File::Spec;
use File::Glob;
use File::Basename;
use Config;

# Find the location of the wxWidget library.

$wxdir //= $ENV{WXDIR} // $ENV{WXWIN};
die( "No wxWidgets folder specified, Please use \"--wxdir\" or set".
     " environment variable WXWIN to the wxWidgets location.\n" )
  unless $wxdir;

die( "wxWidgets not found in $wxdir\n" )
  unless -s w( qw( include wx wx.h ) );

# Find the version. Infer from prefix if not otherwise specified.

unless ( $wxversion ) {
    if ( $wxdir =~ /-([\d.]+)/ ) {
	$wxversion = $1;
    }
    else {
	die( "Cannot infer wxWidgets version from \"$wxdir\"\n" );
    }
}

my @v = split( /\./, $wxversion );
die( "Unrecognized wxWidgets version: $wxversion\n" )
  unless @v >= 2 && @v <= 4;
die( "Unsupported wxWidgets version: $wxversion\n" )
  unless $v[0] == 3 && $v[1] >= 2 && $v[1] <= 4;

# Build the version strings:
#  $wxversion    3.2.9      3.3.1
#  $wxversion_   3_2_9      3_3_1
#  $wxvv         3.002009   3.003001
#  $wxu          32u        33u

$wxversion = join( '.', @v );
my $wxversion_ = join( '_', @v );
my $wxvv = sprintf( "%d.%03d", $v[0], $v[1] );
$wxvv .= sprintf( "%03d", $_ ) for @v[ 2 .. @v-1 ];
my $wxu = join( '', @v[0,1] ) . "u";
warn( "Using wxWidgets $wxversion in $wxdir\n" ) if $verbose;

# GCC bases.
#  $gccbase    gcc_dll   gcc1320_dll
#  $gccbase2   gcc.dll   gcc1320.dll
my $gccbase = basename(glob( w( "lib", "gcc*_dll" ) ));
warn( "Using GCC $gccbase\n" ) if $verbose;
( my $gccbase2 = $gccbase ) =~ s/_dll$/.dll/;

# Alien::wxWidgets compatible values.
my %values =
  ( prefix => w(""),
    alien_base => 'msw_' . $wxversion_ . '_uni_gcc_3_4',
    alien_package => 'Alien::wxWidgets::Config::msw_' . $wxversion_ . '_uni_gcc_3_4',
    c_flags => ' -m64  -O2 -mthreads -Os ',
    compiler => 'g++',
    config =>
    { build => 'multi',
      compiler_kind => 'gcc',
      compiler_version => '3.4',
      debug => 0,
      mslu => 0,
      toolkit => 'msw',
      unicode => 1
    },
    defines => '-D__WXMSW__ -DNDEBUG -D_UNICODE -DWXUSINGDLL -DNOPCH -DNO_GCC_PRAGMA ',
    include_path => join( " ",
			  '-I' . w( "lib" ),
			  '-I' . w( "include" ),
			  '-I' . w( "lib", $gccbase, "mswu" ),
			) . " ",
    link_flags => ' -s -m64 ',
    link_libraries => join( " ",
			    '-L' . w( "lib", $gccbase ),
			    "-lwxmsw${wxu}_core",
			    "-lwxbase${wxu}",
			  ) . " ",
    linker => 'g++',
    shared_library_path => w( "lib", $gccbase ),
    version => $wxvv,
    wx_base_directory => w(""),
  );

# Add the library info.

# Process the .a libs.
for my $lib ( glob( w( "lib", $gccbase, "libwx*.a" ) ) ) {
    next unless $lib =~ /libwx(base|msw)${wxu}(?:_(\w+))?\.a/;
    my $ext = $2;

    # root -> wxbase33u_net
    my $root = "wx" . $1 . "${wxu}";
    $root .= "_$ext" if $ext;

    # imp -> libwxbase33u_net.a
    my $imp = "lib" . $root . ".a";

    # dll -> wxbase33u_net_gcc1320_x64.dll (will be actualized).
    my $dll = $root . "_" . $gccbase2;
    if ( $^O =~ /msw/i ) {
	$dll = w( "lib", $gccbase, $imp );
	$dll = `dlltool -I "$dll"`;
	$dll =~ s/[\n\r]+$//;
    }

    $values{_libraries}{ $ext || "base" } =
      { dll  => $dll,
	lib  => $imp,
	link => "-l$root",
      };
    warn("No shared lib: $dll\n") unless -s w( "lib", $gccbase, $dll );
}

# Dump the config.

if ( $output && $output ne "-" ) {
    close(STDOUT);
    my $o = $output;
    my %v = ( alien_base => $values{alien_base},
	      alien_package => $values{alien_package},
	      alien_config => File::Spec->catfile( split( /::/, $values{alien_package} ) ) . ".pm" );
    $output =~ s;\%\{(\w+)\};$v{$1}//$Config::Config{$1};eg;
    warn("Writing to \"$output\"\n") unless $output eq $o;
    open( STDOUT, '>:utf8', $output )
      or die("$output: $!\n");
}

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
print( "package ", $values{alien_package}, ";\n\n",
       "use strict;\n\n",
       "our \%VALUES;\n\n",
       "{\n",
       "    no strict 'vars';\n",
       "    \%VALUES = \%{\n",
       Dumper(\%values),
       "    };\n",
       "}\n",
       <<'EOD' );

my $key = substr __PACKAGE__, 1 + rindex __PACKAGE__, ':';

sub values { %VALUES, key => $key }

sub config {
   +{ %{$VALUES{config}},
      package       => __PACKAGE__,
      key           => $key,
      version       => $VALUES{version},
      }
}

1;
EOD

################ Subroutines ################

# Construct filename in the $wxdir.
# Normally a trailing separator is stripped, unless the (final) path
# component is an empty string.
sub w( @d ) {
    if ( @d && $d[-1] ne "" ) {
	return File::Spec->catfile( $wxdir, @d );
    }
    $d[-1] = "_";
    my $f = File::Spec->catfile( $wxdir, @d );
    $f =~ s/_$//;
    return $f;
}

################ Subroutines ################

sub app_options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Process options, if any.
    # Make sure defaults are set before returning!
    return unless @ARGV > 0;

    if ( !GetOptions( 'wxdir=s'	     => \$wxdir,
		      'wxversion=s'  => \$wxversion,
		      'output=s'     => \$output,
		      'ident'	     => \$ident,
		      'verbose+'     => \$verbose,
		      'quiet'	     => sub { $verbose = 0 },
		      'trace'	     => \$trace,
		      'help|?'	     => \$help,
		      'debug'	     => \$debug,
		    ) or $help )
    {
	app_usage(2);
    }
    app_ident() if $ident;
}

sub app_ident {
    print STDERR ("This is $my_package [$my_name $my_version]\n");
}

sub app_usage {
    my ($exit) = @_;
    app_ident();
    print STDERR <<EndOfUsage;
Usage: $0 [options]
   --wxdir=XXX          location of the wxWidgets (default \$ENV{WXDIR})
   --wxversion=XXX      wxWidgets version (default inferred from wxdir)
   --output=XXX         output file (default is standard output)
                        may contain %{xxx} to substitute Config values
   --ident		shows identification
   --help		shows a brief help message and exits
   --verbose		provides more verbose information
   --quiet		runs as silently as possible
EndOfUsage
    exit $exit if defined $exit && $exit != 0;
}
