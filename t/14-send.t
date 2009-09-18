use strict;
use warnings;
use Test::More tests => 2;
use FindBin;
use Engage::API::Email::Sender;
use Email::Send::Test;

$ENV{'CONFIG_PATH'} = "$FindBin::Bin/conf";

my $class = 'Engage::API::Email::Sender';
my $api = $class->new;
$class->mailer( 'mailer' => 'Test' );

Email::Send::Test->clear;

$api->send( $api->create(
    'email' => 'test',
    'to' => 'somebody@localhost',
    'loadpaths' => 'template/p',
));

my @emails = Email::Send::Test->emails;
is( scalar(@emails), 1, 'Sent 1 email' );
isa_ok( $emails[0], 'Email::MIME' );
