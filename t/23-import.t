#!perl

use strict;
use warnings;

use Test::More;

use Path::Class;
use FindBin qw($Bin);

use Pinto::Tester;

#------------------------------------------------------------------------------
# Fo this test, we're only using the 'b' repository...

my $fakes    = dir( $Bin, qw(data fakepan repos b) );
my $source   = URI->new("file://$fakes");
my $auth_dir = $fakes->subdir( qw( authors id L LO LOCAL) );

my $us       = 'US';    # The local author
my $them     = 'LOCAL'; # Foreign author (used by CPAN::Faker)

#------------------------------------------------------------------------------
# Setup...

my $t = Pinto::Tester->new( creator_args => {sources => "$source"} );
my $pinto = $t->pinto();

$t->repository_empty_ok();

#------------------------------------------------------------------------------
# Simple pull...

$DB::single = 1;
$t->run_ok('Pull', {norecurse => 1, targets => 'Salad'});
$t->package_ok( "$them/Salad-1.0.0/Salad-1.0.0");

#------------------------------------------------------------------------------
# Add a local copy of a dependency

my $dist = 'Oil-3.0.tar.gz';
my $archive = $auth_dir->file($dist);

$t->run_ok('Add', {archives => $archive, author => $us});
$t->package_ok( "$us/$dist/Oil-3.0" );

#------------------------------------------------------------------------------
# Pull recursive...

$t->run_ok('Pull', {targets => 'Salad'});
$t->package_ok( "$them/Salad-1.0.0/Salad-1.0.0" );

# Salad requires Dressing-0 and Lettuce-1.0
$t->package_ok( "$them/Dressing-v1.9.0/Dressing-v1.9.0" );

# Dressing-v1.9.0 requires Oil-3.0 and Vinegar-v5.1.2.
# But we already have our own local copy of Oil (from above)
$t->package_ok( "$us/Oil-3.0/Oil-3.0", 1);

#------------------------------------------------------------------------------

done_testing();
