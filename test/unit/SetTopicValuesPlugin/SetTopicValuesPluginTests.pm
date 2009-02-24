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

    $this->{session}->finish();
    $this->SUPER::tear_down();
}

sub saveValues {
    my $this = shift;
    my $topic = shift;
    my $text = shift;
    my $settingRef = shift;
    
    my $saveHash =         {
            action              => ['save'],
            topic => [ $this->{test_web} . '.'.$topic ],
            %{$settingRef}
        };
    if (defined($text)) {
        $saveHash->{text} = $text;
    }

    my $query = new Unit::Request(
        $saveHash
    );
    $this->{twiki}->finish();
    $this->{twiki} = new Foswiki( $this->{test_user_login}, $query );
    $this->capture( \&Foswiki::UI::Save::save, $this->{twiki} );
    my ( $meta, $sText ) = Foswiki::Func::readTopic($this->{test_web}, $topic );
    if (defined($text)) {
        $this->assert_matches( $text, $sText );
    }
    $this->assert_null( $meta->get('FORM') );
    foreach my $setKey (keys(%{$settingRef})) {
        my $type = 'PREFERENCE';
        my $key = $setKey;
        $key =~ s/^[Ss]et\+//;

        my $ma = $meta->get($type, $key );
        $this->assert_not_null($ma);
        $this->assert_equals( $settingRef->{$setKey}, $ma->{value} );

        if ($type eq 'PREFERENCE') {
            #TODO: need a new session to force a reload of the preferences :(
            #my $pref = Foswiki::Func::getPreferencesValue($key);
            #$this->assert_equals( $settingRef->{$setKey}, $pref );
#print STDERR "$key = $pref\n";
        }
    }
}

# ----------------------------------------------------------------------
# Purpose:  installed and enabled test
# Verifies: that its worth testing further
sub test_SetTopicValuesPluginEnabled {
    my $this = shift;

    my $contexts = Foswiki::Func::getContext();
    my $enabled  = $contexts->{'SetTopicValuesPluginEnabled'};

    $this->assert($enabled);
}

# ----------------------------------------------------------------------
# Purpose:  create a new topic with a PREFERENCE set
# Verifies: ?Set+SOMEPREF=something works
sub test_set_new_preference_on_new_topic {
    my $this = shift;
    $this->saveValues(
            'DeleteTestSaveScriptTopic',
            "CORRECT",
            {
                   'Set+NEWPREFERENCE' => 'someValue'
            }
           );

print STDERR "DONE\n";
}

# ----------------------------------------------------------------------
# Purpose:  create a new topic with a PREFERENCE set
# Verifies: ?Set+SOMEPREF=something works even when there is a Setting in the topic text
sub test_set_preference_on_new_topic {
    my $this = shift;

    $this->saveValues(
            'DeleteTestSaveScriptTopic',
            "CORRECT\n   * Set NEWPREFERENCE= wrongValue\n bah",
            {
                   'Set+NEWPREFERENCE' => 'someValue'
            }
           );

print STDERR "DONE\n";
}

# ----------------------------------------------------------------------
# Purpose:  change the setting on an existing topic.
# Verifies: ?Set+SOMEPREF=something on an existing topic.
sub test_set_new_preference_on_existing_topic {
    my $this = shift;

    my $text = "CORRECT\n   * Set NEWPREFERENCE= wrongValue\n bah";

    my $oopsUrl =
      Foswiki::Func::saveTopicText( $this->{test_web},
        'DeleteTestSaveScriptTopic', $text);
    $this->assert_matches( '', $oopsUrl );

    $this->saveValues(
            'DeleteTestSaveScriptTopic',
            undef,
            {
                   'Set+NEWPREFERENCE' => 'someValue'
            }
           );

print STDERR "DONE\n";

}

1;
