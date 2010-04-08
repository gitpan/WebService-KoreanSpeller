
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'WebService::KoreanSpeller',
                       'DISTNAME' => 'WebService-KoreanSpeller',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'C.H. Kang <chahkang@gmail.com>',
                       'BUILD_REQUIRES' => {
                                             'Test::More' => '0'
                                           },
                       'ABSTRACT' => 'Korean spellchecker',
                       'EXE_FILES' => [],
                       'VERSION' => '0.004',
                       'PREREQ_PM' => {
                                        'namespace::autoclean' => '0',
                                        'LWP::UserAgent' => '0',
                                        'Any::Moose' => '0',
                                        'Encode' => '0',
                                        'utf8' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



