# ABSTRACT: Simple directory listing with built in url dispatching
package Catalyst::Controller::DirectoryDispatch;
use Moose;
use JSON::Any;
use Try::Tiny;
use namespace::autoclean;

our $VERSION = '0.01';

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(
    'default'   => 'application/json',
    'stash_key' => 'response',
    'map'       => {
        'application/x-www-form-urlencoded' => 'JSON',
        'application/json'                  => 'JSON',
    }
);


has 'root' => (
	is      => 'ro',
	isa     => 'Str',
	default => '/',
);

has 'full_paths' => (
	is      => 'ro',
	isa     => 'Bool',
	default => 0,
);

has 'filter' => (
	is      => 'ro',
	isa     => 'RegexpRef',
	default => sub { qr/.*/ },
);

has 'data_root' => (
	is      => 'ro',
	isa     => 'Str',
	default => 'data',
);


sub setup :Chained('specify.in.subclass.config') :CaptureArgs :PathPart('specify.in.subclass.config') {}


sub list :Chained('setup') PathPart('') :Args {
	my $self = shift;
	my $c = shift;

	my $path = join '/', @_;
	$path = "/$path" if ($path);
	my $full_path = $self->root . $path;

	my $regexp = $self->filter;
	my $files = [];

	try {
		opendir (my $dir, $full_path) or die;
		$files = [ grep { !/$regexp/ } readdir $dir ];
		closedir $dir;
	} catch {
		$c->stash->{response} = {"error" => "Failed to open directory '$full_path'", "success" => JSON::Any::false};
		$c->detach('serialize');
	};

	$files = [ map { "$path/$_" } @$files ] if ($self->full_paths);

	$files = $self->process_files($files);

	$c->stash->{response}->{$self->data_root} = $files;
	$c->stash->{response}->{success} = JSON::Any::true;
}


sub process_files {
	my ( $c, $files ) = @_;
	
	return $files;
}


sub end :Privete {
	my ( $self, $c ) = @_;
	
	$c->res->status(200);
	$c->forward('serialize');
}


sub serialize :ActionClass('Serialize') {}


__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Catalyst::Controller::DirectoryDispatch - A controller for browsing system directories

=head1 SYNOPSIS

	package MyApp::Controller::Browser::Example;
	use Moose;	
	BEGIN { extends 'Catalyst::Controller::DirectoryDispatch' }
	
	__PACKAGE__->config(
		action => { setup => { Chained => '/browser/base', PathPart => 'mydir' } },
		root     => '/home/andy',
		filter     => qr{^\.|.conf$},
		data_root  => 'data',
		full_paths => 1,
	);

=head1 DESCRIPTION

Provides a simple configuration based controller for listing local system directories and dispatching them as URLs.

=head2 Changing Views

The default view for DirectoryDispatch serializes the file list as JSON but it's easy to change it to whatever view you'd like.

	__PACKAGE__->config(
	    'default'   => 'text/html',
	    'map'       => {
	    	'text/html' => [ 'View', 'TT' ],
	    }
	);

Then in your template...

	[% FOREACH node IN response.data %]
	[% node %]
	[% END %]

=head2 Post Processing

If you need to process the files in anyway before they're passed to the view you can override process_files in your controller.

	sub process_files {
		my ($c, $files) = @_;
		
		foreach my $file ( @$files ) {
			# Do stuff...
		}
	}

This is the last thing that happens before the list of files are passed on to the view. $files is sent in as an ArrayRef[Str] but you
are free to return any thing you want as long as the serializer you're using can handle it.

=head1 CONFIGURATION

=head2 root

	is: ro, isa: Str

The folder that will be listed when accessing the controller.

=head2 filter

	is: ro, isa: RegexpRef

A regular expression that will remove matching files or folders from the directory listing. 

=head2 data_root

	is: ro, isa: Str

The name of the key inside $c->stash->{response} where the directory listing will be stored (default: data).

=head2 full_paths

	is: ro, isa: Bool

Returns full paths for the directory listing rather than just the names.

=head1 TODO

Write tests

=head1 AUTHOR

Andy Gorman, agorman@cpan.org

=head1 THANKS

The design for this modules was heavly influenced by the fantastic L<Catalyst::Controller::DBIC::API>.

=head1 COPYRIGHT AND LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
