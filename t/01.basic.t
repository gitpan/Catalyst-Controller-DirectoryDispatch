#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 14;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";

use Test::WWW::Mechanize::Catalyst 'TestDirectoryDispatch';
my $mech = Test::WWW::Mechanize::Catalyst->new;


# Test basic operation
{
	$mech->get_ok('/basic');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, ".";
	my $files = [ readdir $dir ];
	closedir $dir;
	
	print Dumper $files;
	print Dumper $response;
	
	is_deeply( $response, { data => $files, success => 'true' }, 'correct message returned' );
}


{
	$mech->get_ok('/basic/lib');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, "lib";
	my $files = [ readdir $dir ];
	closedir $dir;
	
	is_deeply( $response, { data => $files, success => 'true' }, 'correct message returned' );
}


# Test using a filter
{
	$mech->get_ok('/filter');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, ".";
	my $files = [ grep { !/^\./ } readdir $dir ];
	closedir $dir;
	
	print Dumper $files;
	print Dumper $response;
	
	is_deeply( $response, { data => $files, success => 'true' }, 'correct message returned' );
}


# Test changing data_root
{
	$mech->get_ok('/dataroot');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, ".";
	my $files = [ readdir $dir ];
	closedir $dir;
	
	is_deeply( $response, { test => $files, success => 'true' }, 'correct message returned' );
}


# Test returning full paths
{
	$mech->get_ok('/fullpaths');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, ".";
	my $files = [ readdir $dir ];
	closedir $dir;
	
	$files = [ map { "/$_" } @$files ];
	
	is_deeply( $response, { data => $files, success => 'true' }, 'correct message returned' );
}


{
	$mech->get_ok('/fullpaths/lib');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, "lib";
	my $files = [ readdir $dir ];
	closedir $dir;
	
	$files = [ map { "/lib/$_" } @$files ];
	
	is_deeply( $response, { data => $files, success => 'true' }, 'correct message returned' );
}

# Test post processing
{
	$mech->get_ok('/process');
	my $response = JSON::Any->Load( $mech->content );
	opendir my $dir, ".";
	my $files = [ readdir $dir ];
	closedir $dir;
	
	$files = [ map { "Andy was here: $_" } @$files ];
	
	is_deeply( $response, { data => $files, success => 'true' }, 'correct message returned' );
}