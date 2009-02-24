use strict;

package SetTopicValuesPluginTests;

use base qw(FoswikiFnTestCase);

use strict;

use Foswiki;
use Foswiki::UI::Save;
use Unit::Request;
use Unit::Response;

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

# Set up the test fixture
sub set_up {
    my $this = shift;

    $this->SUPER::set_up();
    my $query = new Unit::Request();
    $Foswiki::cfg{Plugins}{SetTopicValuesPlugin}{Enabled} = 1;
    $this->{session}  = Foswiki->new( undef, $query );
    $this->{request}  = $query;
    $this->{response} = new Unit::Response();
}

sub NOtear_down {
    my $this = shift;

    $this->{session} ->finish();
    $this->SUPER::tear_down();
}

# ----------------------------------------------------------------------
# Purpose:  installed and enabled test
# Verifies: that its worth testing further
sub test_SetTopicValuesPluginEnabled {
    my $this = shift;
    
    my $contexts = Foswiki::Func::getContext();
    my $enabled = $contexts->{'SetTopicValuesPluginEnabled'};
    
    $this->assert($enabled);
}

# ----------------------------------------------------------------------
# Purpose:  create a new topic with a PREFERENCE set
# Verifies: ?Set+SOMEPREF=something works
sub test_set_new_preference_on_new_topic {
    my $this = shift;
    
    my $query = new Unit::Request({
        text => [ 'CORRECT' ],
        'Set+NEWPREFERENCE' => 'someValue',
        action => [ 'save' ],
        topic => [ $this->{test_web}.'.DeleteTestSaveScriptTopic' ]
       });
    $this->{twiki}->finish();
    $this->{twiki} = new Foswiki( $this->{test_user_login}, $query );
    $this->capture( \&Foswiki::UI::Save::save, $this->{twiki});
    my($meta, $text) = $this->{twiki}->{store}->readTopic(undef, $this->{test_web},
                                                 'DeleteTestSaveScriptTopic');
    $this->assert_matches(qr/CORRECT/, $text);
    $this->assert_null($meta->get('FORM'));

    my $ma = $meta->get( 'PREFERENCE', 'NEWPREFERENCE' );
    $this->assert_not_null($ma);
    $this->assert_equals('someValue', $ma->{value});
}

# ----------------------------------------------------------------------
# Purpose:  create a new topic with a PREFERENCE set
# Verifies: ?Set+SOMEPREF=something works even when there is a Setting in the topic text
sub test_set_preference_on_new_topic {
    my $this = shift;
    
    my $text = "CORRECT\n   * Set NEWPREFERENCE= wrongValue\n bah";
    
    my $query = new Unit::Request({
        text => [ $text ],
        'Set+NEWPREFERENCE' => 'someValue',
        action => [ 'save' ],
        topic => [ $this->{test_web}.'.DeleteTestSaveScriptTopic' ]
       });
    $this->{twiki}->finish();
    $this->{twiki} = new Foswiki( $this->{test_user_login}, $query );
    $this->capture( \&Foswiki::UI::Save::save, $this->{twiki});
    my($meta, $sText) = $this->{twiki}->{store}->readTopic(undef, $this->{test_web},
                                                 'DeleteTestSaveScriptTopic');
    $this->assert_matches($text, $sText);
    $this->assert_null($meta->get('FORM'));

    my $ma = $meta->get( 'PREFERENCE', 'NEWPREFERENCE' );
    $this->assert_not_null($ma);
    $this->assert_equals('someValue', $ma->{value});
}

# ----------------------------------------------------------------------
# Purpose:  create a new topic with a PREFERENCE set
# Verifies: ?Set+SOMEPREF=something works even when there is a Setting in the topic text
sub test_set_preference_on_new_topic {
    my $this = shift;
    
    my $text = "CORRECT";
    
    my $query = new Unit::Request({
        text => [ $text ],
        'Set+NEWPREFERENCE' => 'someValue',
        action => [ 'save' ],
        topic => [ $this->{test_web}.'.DeleteTestSaveScriptTopic' ]
       });
    $this->{twiki}->finish();
    $this->{twiki} = new Foswiki( $this->{test_user_login}, $query );
    $this->capture( \&Foswiki::UI::Save::save, $this->{twiki});
    my($meta, $sText) = $this->{twiki}->{store}->readTopic(undef, $this->{test_web},
                                                 'DeleteTestSaveScriptTopic');
    $this->assert_matches($text, $sText);
    $this->assert_null($meta->get('FORM'));

    my $ma = $meta->get( 'PREFERENCE', 'NEWPREFERENCE' );
    $this->assert_not_null($ma);
    $this->assert_equals('someValue', $ma->{value});
}

1;
