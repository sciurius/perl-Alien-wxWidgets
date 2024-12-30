package My::Build::MacOSX_wx_config;

use strict;
use base qw(My::Build::Any_wx_config);

use Config;

sub awx_wx_config_data {
    my $self = shift;
    return $self->{awx_data} if $self->{awx_data};
    my %data = ( linkflags => '', %{$self->SUPER::awx_wx_config_data} );

    # MakeMaker does not like some options
    $data{libs} =~ s{-framework\s+\w+}{}g;
    $data{libs} =~ s{-isysroot\s+\S+}{}g;
    $data{libs} =~ s{-L/usr/local/lib\s}{}g;

    $data{libs} =~ s{\s(-arch\s+\w+)}
                    {$data{linkflags} .= " $1 ";
                     $data{cxxflags} .= " $1 ";
                     ' '}eg;

    $data{cxx} =~ s{-isysroot\s+\S+}{}g;
    $data{ld} = $data{cxx};
    $data{cxxflags} .= ' -UWX_PRECOMP ';

    $self->{awx_data} = \%data;
}

sub awx_configure {
    my $self = shift;
    my %config = $self->SUPER::awx_configure;

    $config{link_flags} .= $self->wx_config( 'linkflags' );

    return %config;
}

sub wxwidgets_configure_extra_flags {
    my( $self ) = @_;
    my $extra_flags = $self->notes( 'extraflags' );
    
    if($extra_flags) {
	# user has given overrides
    	if( $self->notes( 'graphicscontext' ) ) {
			$extra_flags .= ' --enable-graphics_ctx';
    	}
        return $extra_flags;
    }

    my $darwinver = 0;
    if(`uname -r` =~ /^(\d+)\./) {
        $darwinver = $1;
    }
    
    # we are determining extra flags
    $extra_flags = '';
    
    # on Snow Leopard, and above force wxWidgets 2.8.x builds to be 32-bit;
    # force 2.9 builds to be 32 bit too if we have a 32 bit Perl
    
    if(     $darwinver >= 10
        &&  `sysctl hw.cpu64bit_capable` =~ /^hw.cpu64bit_capable: 1/
        && ( $self->awx_version_type == 2
             || $Config{ptrsize} == 4 ) ) {
             
        print "Forcing wxWidgets build to 32 bit\n";
		        $extra_flags .= ' ' . join ' ', map { qq{$_="-arch i386"} }
		                                     qw(CFLAGS CXXFLAGS LDFLAGS
                                        OBJCFLAGS OBJCXXFLAGS);
    }
    
#    if ( $darwinver >= 13 ) {
#	    # we can't currently build with Xcode 5 on Mavericks
#	    my $xcodestring = qx(xcodebuild -version) || '';
#	    if ($xcodestring =~ /Xcode\s+(\d+)/ ) {
#	        my $xcodever = $1;
#	        if ( $xcodever >= 5) {
#		        print <<EOX;
#=======================================================================
#wxPerl does not currently support building on Mac OSX Mavericks and
#above with Xcode 5.x or greater.
#If you wish to develop using wxPerl on this machine you should remove
#XCode 5.x and download Xcode 4.6.3 from the Apple developer site.
#=======================================================================
#EOX
#                exit 1;
#	        }
#	    }
#    }
    
    # on Snow Leopard and above, force use of available SDK and min versions
    
    if( $darwinver >= 10 ) {
        
	# SDK 10.7 will not work if we have SDK 10.8 installed too - so reverse order
        for my $sdkversion ( qw( 10.9 10.8 10.7 10.6 ) ) {
            my $sdk1 = qq(/Developer/SDKs/MacOSX${sdkversion}.sdk);
			my $sdk2 = qq(/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${sdkversion}.sdk);
    		my $macossdk = ( -d $sdk2 ) ? $sdk2 : $sdk1;
    		if( -d $macossdk ) {
                my $macosmin = ( $sdkversion =~ /^10\.(8|7|6)$/ ) ? '10.6' : '10.7';
    		    $extra_flags .= qq( --with-macosx-version-min=${macosmin} --with-macosx-sdk=${macossdk});
    		    last;
    		}
    	}
    }
    
    $extra_flags .= ' --enable-graphics_ctx';
    
    # now check for flags needed for different xcode versions
    {
        my $xcodestring = qx(xcodebuild -version) || '';
	    if ($xcodestring =~ /Xcode\s+(\d+)\.(\d+)/ ) {
	        my $majorxcodever = $1;
	        my $minorxcodever = $2;
            
            if (( $majorxcodever > 4 ) || ( $majorxcodever == 4 && $minorxcodever > 3 )) {
                $extra_flags .= q( CC=clang CXX=clang++ CXXFLAGS="-stdlib=libc++ -std=c++11" OBJCXXFLAGS="-stdlib=libc++ -std=c++11" LDFLAGS=-stdlib=libc++);
            }
        }
    }
    

    return $extra_flags;
}

sub awx_build_toolkit {
    my $self = shift;
    # use Cocoa for OS X wxWidgets >= 2.9
    # we don't support lower than 2.8 anymore
    if( $self->awx_version_type == 2) {
    	return 'mac';
    } else {
        return 'osx_cocoa';
    }
}

sub awx_dlext { 'dylib' }

sub build_wxwidgets {
    my( $self ) = @_;

    # can't build wxWidgets 2.8.x with 64 bit Perl
    if(    $Config{ptrsize} == 8
        && $self->awx_version_type == 2 ) {
        print <<EOT;
=======================================================================
The 2.8.x wxWidgets for OS X does not support 64-bit. In order to build
wxPerl you will need to either recompile Perl as a 32-bit binary or (if
using the Apple-provided Perl) force it to run in 32-bit mode (see "man
perl").  Alpha 64-bit wx for OS X is in 2.9.x, but untested in wxPerl.
=======================================================================
EOT
        exit 1;
    }

    $self->SUPER::build_wxwidgets;
}

1;
