use strict;
use warnings;
use Test::Base;
use Test::Exception;
use FindBin;
use POSIX qw/locale_h strftime/;
use Engage::API::Email::Sender;

setlocale( LC_ALL, 'C' );
$ENV{'TZ'} = 'UTC';
$ENV{'CONFIG_PATH'} = "$FindBin::Bin/conf";

my $class = 'Engage::API::Email::Sender';
my $api = $class->new;
$class->mailer( 'mailer' => 'Test' );

plan tests => 1 * blocks;

sub strip_date {
    $_[0] =~ s/(?<=Date: )..., \d\d ... \d{4} \d\d:\d\d:\d\d [+-]\d{4}//o;
    $_[0];
}

filters {
    input    => [qw/yaml/],
    expected => [qw/trim/],
};

run {
    my $block = shift;
    my %args = %{ $block->input || +{} };
    if ( $block->name =~ /^throw/o ) {
        throws_ok {
            $api->create(%args)->as_string
        } 'Engage::Exception', $block->name;
    }
    else {
        is(
            strip_date( $api->create(%args)->as_string ),
            $block->expected,
            $block->name
        );
    }
};

__DATA__
=== basic
--- input
email: test
to: somebody@example.com
loadpaths: 'template/p'
vars:
  name: John
--- expected
Subject: API Email Subject
To: somebody@example.com
From: framework@example.com
Date: 
MIME-Version: 1.0

Hello, John!

=== throws not enough
--- input
=== throws not enough
--- input
to: somebody@example.com
=== throws not enough
--- input
to: somebody@example.com
from: framework@example.com
=== throws specify template or body
--- input
to: somebody@example.com
from: framework@example.com
subject: API Email Subject
=== specify body
--- input
to: somebody@example.com
from: framework@example.com
subject: API Email Subject
body: 'specify body'
--- expected chomp
Subject: API Email Subject
To: somebody@example.com
From: framework@example.com
Date: 
MIME-Version: 1.0

specify body

=== overwrite by body
--- input
email: test
to: somebody@example.com
body: 'specify body'
--- expected chomp
Subject: API Email Subject
To: somebody@example.com
From: framework@example.com
Date: 
MIME-Version: 1.0

specify body
