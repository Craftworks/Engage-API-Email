use strict;
use warnings;
use Test::More tests => 3;
use Engage::API::Email::Sender;

my $class = 'Engage::API::Email::Sender';
my $base  = 'Email::Send';

isa_ok( $class->_sender, $base, 'default' );
isa_ok( $class->mailer(
    'mailer' => 'Test',
    'mailer_args' => {
        'Host'  => 'localhost',
        'Hello' => 'Email Test',
    },
), $base, 'change config' );
isa_ok( $class->_sender, $base, 'after changing' );
