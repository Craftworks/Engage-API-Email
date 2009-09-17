package Engage::API::Email;

use Moose;
use Encode;
use Email::MIME;
use Email::Send;
use namespace::clean -except => 'meta';

our $AUTHORITY = 'cpan:CRAFTWORK';
our $VERSION = '0.001';
$VERSION = eval $VERSION;

1;

__END__

=head1 NAME

Engage::API::Email - The fantastic new Engage::API::Email!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Engage::API::Email;

    my $foo = Engage::API::Email->new;
    ...

=head1 DESCRIPTION

The fantastic new Engage::API::Email!

=head1 EXPORTS

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 METHODS

=head2 method1

=head1 AUTHOR

Craftworks, C<< <craftwork at cpan org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-engage-api-email@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright (C) 2009 Craftworks, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
