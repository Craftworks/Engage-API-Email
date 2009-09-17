use strict;
use warnings;
use ExtUtils::MakeMaker;
use Test::Dependencies
    exclude => [qw/Test::Dependencies Engage::API::Email/],
    style   => 'light';

ok_dependencies();
