use inc::Module::Install;

name     'Engage-API-Email';
all_from 'lib/Engage/API/Email.pm';
author   q{Craftworks <craftwork at cpan org>};
license  'perl';

build_requires 'Test::More';
build_requires 'Test::Base';
build_requires 'Test::UseAllModules';

requires 'namespace::clean';
requires 'Moose';
requires 'Encode' => '2.13';
requires 'Email::MIME';
requires 'Email::Send';

author_tests 'xt';

auto_install;
auto_manifest;

WriteAll;
