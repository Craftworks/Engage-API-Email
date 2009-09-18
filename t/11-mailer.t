use strict;
use warnings;
use FindBin;
use Test::Base;
use Test::Exception;
use Engage::API::Email::Sender;

$ENV{'CONFIG_PATH'} = "$FindBin::Bin/conf";

plan tests => 1 + 1 * blocks;

my $class = 'Engage::API::Email::Sender';

throws_ok { $class->new->mailer } 'Engage::Exception', 'object method';

sub mailer {
    $class->mailer(shift);
    $class->_mailer;
}

filters {
    input   => [qw/yaml mailer/],
    expected=> [qw/yaml/],
};

run_is_deeply;

__DATA__
=== default
--- input
--- expected
mailer: 'SMTP'
mailer_args:
  Host: 'localhost'
  Hello: 'localhost'

=== mailer
--- input
mailer: 'Test'
--- expected
mailer: 'Test'
mailer_args:
  Host: 'localhost'
  Hello: 'localhost'

=== mailer_args
--- input
mailer_args:
  Host: '127.0.0.1'
--- expected
mailer: 'Test'
mailer_args:
  Host: '127.0.0.1'

=== unknown key
--- input
foo: 1
bar: 2
baz: 3
--- expected
mailer: 'Test'
mailer_args:
  Host: '127.0.0.1'
