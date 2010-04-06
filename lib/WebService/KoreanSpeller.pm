package WebService::KoreanSpeller;
# ENCODING: utf-8
# ABSTRACT: Korean spellchecker
our $VERSION = '0.001';
$VERSION = eval $VERSION;

use Any::Moose;
use Any::Moose '::Util::TypeConstraints';
use LWP::UserAgent;
use utf8;
use Encode qw/encode decode/;
use namespace::autoclean;

subtype 'UTF8FlagOnString'
    => as 'Str'
    => where { utf8::is_utf8($_) };

has 'text' => ( is => 'ro', isa => 'UTF8FlagOnString', required => 1 );

sub spellcheck {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(POST => 'http://speller.cs.pusan.ac.kr/WebSpell_ISAPI.dll?Check');
    $req->content_type('application/x-www-form-urlencoded');
    my $text = $self->text;
    $req->content('text1='.encode('euc-kr', $text));
    my $res = $ua->request($req);
    die unless $res->is_success;
    my $content = decode('euc-kr', $res->as_string);

    my ($table) = $content =~ m{<table border=1.*?>(.*?)</table>}s;
    my @rows = $table =~ m{<tr>(.*?)</tr>}sg;
    my @items;
    foreach my $row (@rows) {
        my %item;
        @item{qw/incorrect correct comment/} =
            ( map { $_ =~s/<.*?br>/\n/g;
                    $_ =~s/^\s+//s;
                    $_ =~s/\s+$//s;
                    $_ =~s/\s+\[ NARAINFOTECH.*?\]//s;
                    $_ } $row =~ m{<td.*?>(.*?)</td>}sg )[0..2];
        $text =~ m/$item{incorrect}/g;
        $item{position} = ( pos $text ) - ( length $item{incorrect} );
        push @items, \%item;
    }
    return @items;
}

__PACKAGE__->meta->make_immutable;
1;


__END__
=pod

=encoding utf-8

=head1 NAME

WebService::KoreanSpeller - Korean spellchecker

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use WebService::KoreanSpeller;
    use utf8;

    my $checker = WebService::KoreanSpeller->new( text=> '안뇽하세요? 방갑습니다.' );
    my @results = $checker->spellcheck;   # returns array of hashes
    binmode STDOUT, ':encoding(UTF-8)';
    foreach my $item (@results) {
        print $item->{position}, "\n";    # index on the original text (starting from 0)
        print $item->{incorrect}, " -> "; # incorrect spelling
        print $item->{correct}, "\n";     # correct spelling
        print $item->{comment}, "\n";     # comment about spelling
        print "------------------------------\n";
    }


    OUTPUT:

    0
    안뇽하세요 -> 안녕하세요
    표준 발음·표준어 오류
    어린이들의 발음을 흉내내어 '안뇽'이라고 말하는 사람들이 종종 있습니다. 특히, 글을 쓸 때에는 이러한 단어를 쓰지 않도록 합시다.
    ------------------------------
    7
    방갑습니다 -> 반갑습니다
    약어 사용 오류
    오늘날 통신에서 자주 쓰는 은어입니다.
    ------------------------------

=head1 DESCRIPTION

    This module provides a Perl interface to the Web-based korean speller service( 온라인 한국어 맞춤법/문법 검사기 - http://speller.cs.pusan.ac.kr ).

=head1 CAUTION

    I'm afraid we don't have a good open source korean spell checker. but there is a decent proprietary service that runs on the online website( 온라인 한국어 맞춤법/문법 검사기 - http://speller.cs.pusan.ac.kr ). So I made this module with web-scrapping approach, this is easy to mess up if they change layout of the website. Let me know if this does not work. *This module follows the same terms of the original service agreement.*

=head1 METHODS

=head2 new( text => 'text for spell check' )

Returns an obejct instance of this module. text should be "Unicode string"(a.k.a. perl's internal format - utf8 encoding/utf8 flag on)

=head2 spellcheck

Returns results as array of hases, See SYNOPSIS. you can easily convert AoH to JSON or XML.

=head1 AUTHOR

  C.H. Kang <chahkang@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by C.H. Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

