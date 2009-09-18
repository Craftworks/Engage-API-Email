package Engage::API::Email::Sender;

use Moose;
use Engage::Exception;
use Encode;
use List::MoreUtils 'all';
use Email::Send ();
use Email::MIME::Creator;
use namespace::clean -except => 'meta';
extends 'Engage::API';
with 'Engage::Class::Data';

our $AUTHORITY = 'cpan:CRAFTWORK';
our $VERSION = '0.001';
$VERSION = eval $VERSION;

has 'view_class' => (
    is  => 'ro',
    isa => 'Str',
    default => sub {
        my $self = shift;
        defined $self->config->{'view_class'}
              ? $self->config->{'view_class'} : 'TT';
    },
    lazy => 1,
);

__PACKAGE__->mk_classdata( '_sender' );
__PACKAGE__->mk_classdata( '_mailer' => {
    'mailer' => 'SMTP',
    'mailer_args' => {
        'Host'  => 'localhost',
        'Hello' => 'localhost',
    },
} );

__PACKAGE__->add_loader('View');
__PACKAGE__->meta->make_immutable;

sub import {
    shift->mailer( @_ );
}

sub _build_sender {
    my $class = shift;

    my $sender = Email::Send->new;
    my $mailer = $class->_mailer->{'mailer'};
    my $args   = $class->_mailer->{'mailer_args'};

    Engage::Exception->throw(qq/mailer "$mailer" is not supported, see Email::Send/)
        unless $sender->mailer_available( $class->_mailer->{'mailer'} );

    # For SMTP Auth
    if ( $mailer eq 'SMTP' && $args->{'username'} ) {
        eval {
            require MIME::Base64;
            require Authen::SASL;
        };
        if ($@) {
            Engage::Exception->throw(q/Needs MIME::Base64 and Authen::SASL todo auth/);
        }
    }

    if ( ref $args eq 'HASH' ) {
        $sender->mailer_args([ %$args ]);
    }
    elsif ( ref $args eq 'ARRAY' ) {
        $sender->mailer_args( $args );
    }
    else {
        Engage::Exception->throw(q/Invalid mailer_args specified, see Email::Send/);
    }

    $class->_sender( $sender );
}

sub BUILD {
    my $self  = shift;
    my $class = ref $self;
    $class->_build_sender unless $class->_sender;
}

sub mailer {
    my $class = shift;
    Engage::Exception->throw(q/mailer() is a class method, not an object method/)
        if blessed $class;
    my %args = ( @_ == 1 ? %{ $_[0] || +{} } : @_ );
    for (qw/mailer mailer_args/) {
        $class->_mailer->{$_} = $args{$_} if $args{$_};
    }
    $class->_build_sender;
}

sub create {
    my ( $self, %args ) = @_;

    local $ENV{'TZ'} = 'UTC';
    my $message = Email::MIME->create(
        header => [ $self->__create_header( %args ) ],
        body   => $self->__create_body( %args ),
    );
    Engage::Exception->throw(q/Unable to create message/) unless $message;

    return $message;
}

sub __create_header {
    my ( $self, %args ) = @_;

    my %header;

    if ( defined $args{'email'}
        && (my $config = $self->config->{'email'}{$args{'email'}} )) {
        $header{'From'}    = $config->{'from'};
        $header{'Subject'} = $config->{'subject'};
    }

    $header{'To'}      = $args{'to'}      if $args{'to'};
    $header{'From'}    = $args{'from'}    if $args{'from'};
    $header{'Subject'} = $args{'subject'} if $args{'subject'};

    Engage::Exception->throw(q/Not enough header/)
        unless (all { defined $header{$_} && length $header{$_} } qw(To From Subject));

    $header{'Subject'} = Encode::encode('MIME-Header', $header{'Subject'});

    # Merge additional headers
    if ( defined $args{'header'} ) {
        %header = (%header, @{$args{'header'}});
    }

    return %header;
}

sub __create_body {
    my ( $self, %args ) = @_;

    my ( $body, $template ) = ('') x 2;

    if ( defined $args{'email'}
        && (my $config = $self->config->{'email'}{$args{'email'}} )) {
        $template = $config->{'template'};
    }
    if ( $args{'template'} ) {
        $template = $args{'template'};
    }
    $body = $args{'body'} if $args{'body'};

    Engage::Exception->throw(q/Specify template or body/)
        unless ( length $template || length $body );

    # Render template
    if ( length $template && !length $body ) {
        $body = $self->__render( %args, template => $template );
    }

    return $body
}

sub __render {
    my ( $self, %args ) = @_;
    my $view = $self->view( $self->view_class );
    $view->loadpaths([ $args{'loadpaths'} ]);
    $view->template( $args{'template'} );
    $view->data( $args{'vars'} || +{} );
    my $body = $view->render;
    Catalyst::Exception->throw(q/Coudn't render template/) unless defined $body;
    return $body;
}

sub send {
    my ( $self, $message ) = @_;

    Engage::Exception->throw(q/Invalid object specified, must be Email::MIME/)
        unless ref $message and blessed $message eq 'Email::MIME';

    my $rv = $self->_sender->send( $message );
    Engage::Exception->throw("$rv") unless $rv;
    return $rv;
}

sub sendmail {
    my ( $self, %args ) = @_;
    my $message = $self->create( %args );
    $self->send( $message );
}

1;

__END__

=head1 NAME

Engage::API::Email::Sender - Engage Email Sender API

=head1 SYNOPSIS

  use Engage::API::Email::Sender;

  Engage::API::Email::Sender->mailer(
    'mailer' => 'Sendmail',
  );

  my $sender = Engage::API::Email::Sender->new;
  $sender->sendmail(
    'to' => 'somebody@example.com',
    'from' => 'somebody@example.com',
    'subject' => 'sender test',
    'body' => 'blah blah blah',
  );

  or

  my $message = $sender->create(
    'to' => 'somebody@example.com',
    'from' => 'somebody@example.com',
    'subject' => 'sender test',
    'body' => 'blah blah blah',
  );
  $sender->send( $message );

=head1 METHODS

=head2 mailer

XXX: TODO

=head2 sendmail

shortcut for create() and send()

=head2 create

XXX: TODO

=head2 send

  my $rv = $sender->send( $message );

Send a message using the predetermined mailer and mailer arguments.

The first argument you pass to send is an email message. It must be
in some format that "Email::Abstract" can understand. If you don't
have "Email::Abstract" installed then sending as plain text or an
"Email::Simple" object will do.

=head1 SEE ALSO

L<Email::Send>, L<Email::MIME>, L<Email::MIME::Creator>, L<Engage>, L<Engage::API>

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
