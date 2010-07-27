
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Simple directory listing with built in url dispatching',
  'AUTHOR' => 'Andy Gorman <agorman@cpan.org>',
  'BUILD_REQUIRES' => {
    'Catalyst' => '0',
    'Catalyst::Runtime' => '5.80',
    'English' => '0',
    'FindBin' => '0',
    'Test::More' => '0',
    'Test::WWW::Mechanize::Catalyst' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Catalyst-Controller-DirectoryDispatch',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Catalyst::Controller::DirectoryDispatch',
  'PREREQ_PM' => {
    'Catalyst::Controller' => '0',
    'JSON::Any' => '0',
    'Moose' => '0',
    'Try::Tiny' => '0',
    'namespace::autoclean' => '0'
  },
  'VERSION' => '0.03',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



