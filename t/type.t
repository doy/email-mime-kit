#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Email::MIME::Kit;

BEGIN {
    package My::Reader;
    use Moose;
    extends 'Email::MIME::Kit::ManifestReader::JSON';

    __PACKAGE__->meta->make_immutable;
    $INC{'My/Reader.pm'} = __FILE__;
}

BEGIN {
    package My::Reader2;
    use Moose;
    extends 'Email::MIME::Kit::ManifestReader::JSON';

    # this is an exact copy of read_manifest from
    # Email::MIME::Kit::ManifestReader::JSON
    sub read_manifest {
        my ($self) = @_;

        my $json_ref = $self->kit->kit_reader->get_kit_entry('manifest.json');

        my $content = JSON->new->decode($$json_ref);
    }

    __PACKAGE__->meta->make_immutable;
    $INC{'My/Reader2.pm'} = __FILE__;
}

BEGIN {
    package My::Kit;
    use Moose;
    extends 'Email::MIME::Kit';
    has '+manifest_reader' => (
        default => '=My::Reader',
    );
    __PACKAGE__->meta->make_immutable;
    $INC{'My/Kit.pm'} = __FILE__;
}

BEGIN {
    package My::Kit2;
    use Moose;
    extends 'Email::MIME::Kit';
    has '+manifest_reader' => (
        default => '=My::Reader2',
    );
    __PACKAGE__->meta->make_immutable;
    $INC{'My/Kit2.pm'} = __FILE__;
}

{
    my $kit = My::Kit->new({source => 't/kits/type.mkit'});
    my $email = $kit->assemble;
    is(($email->parts)[0]->content_type, "text/html");
}

{
    my $kit = My::Kit2->new({source => 't/kits/type.mkit'});
    my $email = $kit->assemble;
    is(($email->parts)[0]->content_type, "text/html");
}

done_testing;
