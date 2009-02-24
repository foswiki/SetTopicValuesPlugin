# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright 2008-2009 SvenDowideit@fosiki.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::SetTopicValuesPlugin;

use strict;

require Foswiki::Func;    # The plugins API
require Foswiki::Plugins; # For the API version

our $VERSION = '$Rev: 1340 $';
our $RELEASE = '$Date: 2008-12-15 04:49:56 +1100 (Mon, 15 Dec 2008) $';
our $SHORTDESCRIPTION = 'Set addressible sub-elements of topics';
our $NO_PREFS_IN_TOPIC = 1;
our $beforeSaveHandlerONCE;
our $debug;

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
                                     __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }
    undef $beforeSaveHandlerONCE;
    
    return 1;
}

sub afterSaveHandler {
    #prevent nested calls
    return if (defined($beforeSaveHandlerONCE));
    #$beforeSaveHandlerONCE = 1;
    
print STDERR "afterSaveHandler - (".$_[2].".".$_[1].") ".$_[3]->getEmbeddedStoreForm()."\n";
    
    # do not uncomment, use $_[0], $_[1]... instead
    ### my ( $text, $topic, $web, $meta ) = @_;
    Foswiki::Func::writeDebug( "- SetTopicValuesPlugin::beforeSaveHandler( $_[2].$_[1] )" ) if $debug;
    my $cgi = TWiki::Func::getCgiQuery();
    
#TODO: we should be transactional by default - test that we can write to all topics, and take out leases
    
    #?set+SOMESETTGIN=value
    #?set+Sandbox.TestTopic5:preferences[EditDocumentState]=SomeValue
    #?set+Sandbox.TestTopic5:fields[EditDocumentState]=SomeValue
    #http://quad/airdrilling/bin/save/Sandbox/TestTopic55?set+Sandbox.TestTopic5Edit:fields[EditDocumentState]=SomeValue
    my @paramKeys = $cgi->param();
    foreach my $key (@paramKeys) {
        if ($key =~ /^[Ss]et\+(.*)$/ ) {
            my $addr = $1;
            
            my $webTopic = $_[2].'.'.$_[1];
            if ($addr =~ /^(.*):(.*)$/ ) {
                $webTopic = $1;
                $addr = $2;
            }
            my $type = 'PREFERENCE';
            if ($addr =~ /^(.*)\[(.*)\]$/ ) {
                $type = uc($1);
                $addr = $2;
            }
            
            my $value = $cgi->param($key);
print STDERR "Set ($webTopic).($type)\($addr) = ($value)\n";
            my ($sWeb, $sTopic) = TWiki::Func::normalizeWebTopicName($_[2], $webTopic);
            if (TWiki::Func::topicExists($sWeb, $sTopic)) {
                my( $sMeta, $sText ) = TWiki::Func::readTopic($sWeb, $sTopic);
                $type =~ s/S$//;
                my $ma = $sMeta->get( $type, $addr );
print STDERR "test $ma";
                $ma->{value} = $value;
                $sMeta->putKeyed($type, $ma );
                TWiki::Func::saveTopic($sWeb, $sTopic, $sMeta, $sText);
            }
        }
    }
    
}

1;
__END__
This copyright information applies to the SetTopicValuesPlugin:

# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# SetTopicValuesPlugin is # This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# For licensing info read LICENSE file in the Foswiki root.
