package Email::MIME::Kit::Assembler::FromString;
use Moose;

with 'Email::MIME::Kit::Role::Assembler::Simple';

use Email::MIME::Creator;

sub assemble {
  my ($self, $stash) = @_;

  my $body = $self->manifest->{body};

  # I really shouldn't have to do this, but I'm not going to go screw around
  # with @#$@#$ Email::Simple/MIME just to deal with it right now. -- rjbs,
  # 2009-01-19
  $body .= "\x0d\x0a" unless $body =~ /[\x0d|\x0a]\z/;

  my %attr = %{ $self->manifest->{attributes} || {} };
  $attr{content_type} = $attr{content_type} || 'text/plain';

  my $email = Email::MIME->create(
    attributes => \%attr,
    header     => $self->_prep_header($self->manifest->{header}, $stash),
    body       => $body,
  );

  my $container = $self->_contain_attachments($email, $stash);
}

no Moose;
1;