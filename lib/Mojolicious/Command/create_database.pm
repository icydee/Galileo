package Mojolicious::Command::setup_database;
use Mojo::Base 'Mojolicious::Command';

has description => "Setup the database for you MojoCMS application.\n";
has usage       => "usage: $0 setup_database [username]\n";

use Mojo::JSON;
my $json = Mojo::JSON->new();

sub run {
  my ($self, $user) = @_;

  my $schema = $self->app->db_connect;

  $schema->deploy;

  my $admin = $schema->resultset('User')->create({
    name => $user || 'admin',
    pass => 'pass',
    is_author => 1,
    is_admin  => 1,
  });

  $schema->resultset('Page')->create({
    name      => 'home',
    title     => 'Home Page',
    html      => '<p>Welcome to the site!</p>',
    md        => 'Welcome to the site!',
    author_id => $admin->id,
  });

  my $about = $schema->resultset('Page')->create({
    name      => 'about',
    title     => 'About Me',
    html      => '<p>Some really cool stuff about me</p>',
    md        => 'Some really cool stuff about me',
    author_id => $admin->id,
  });

  $schema->resultset('Menu')->create({
    name => 'main',
    list => $json->encode( [ $about->id ] ), 
    html => sprintf( '<li><a href="/pages/%s">%s</a></li>', $about->name, $about->title ),
  });
}

1;
