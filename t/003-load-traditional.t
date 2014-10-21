#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Test::Memory::Cycle;
use Test::Deep grep { !m/blessed/ } @Test::Deep::EXPORT;

plan qw/no_plan/;

use t::Test::Project;
use t::Test::Project::Modeler;

my $schema = t::Test::Project->schema;
my $modeler = t::Test::Project::Modeler->new( schema => $schema );

memory_cycle_ok( $schema );
memory_cycle_ok( $modeler );

ok( my $artist = $modeler->create( 'Artist' => { name => "apple" } ) );
is( $artist->name, "apple" );
memory_cycle_ok( $artist );
is( $artist->model_source->relationship( "cds" )->model_class, "t::Test::Project::Model::Cd" );
ok( my $cd = $artist->create_related( cds => { title => "banana" }) );
is( $cd->model_source->relationship( "artist" )->model_class, "t::Test::Project::Model::Artist::Rock" );
memory_cycle_ok( $cd );
is( $cd->title, "banana" );
ok( $artist->model_storage->id );
ok( $artist->id );
is( $artist->id, $artist->model_storage->id );
ok( $cd->artist );
is( ref $cd->artist, "t::Test::Project::Model::Artist::Rock" );
ok( $cd->artist->model_storage->id );
is( $artist->id, $cd->artist->model_storage->id );
ok( $cd->id );

1;
