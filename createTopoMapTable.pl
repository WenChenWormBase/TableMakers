#!/usr/bin/perl 

use strict;
use Ace;

#my %xCordMap; 
#my %yCordMap;
#my %profileMap;
#my %mountainMap;
#my %geneMap;

my ($skmap, $exprProfile, $xCord, $yCord, $gene, $genename, $pcr, $mr, $mountain);
#my @stuff;

open (OUT, ">TopoMap.csv") || die "can't open $!";
print OUT "Expr_profile\tGene ID\tGene Name\tMountain\tX Coordinate\tY Coordinate\n";

#---------- Connecting to current WormBase ----------------------

print "connecting to WS_current ...\n";
my $tace='/usr/local/bin/tace';
my $acedbpath='/home/citace/WS/acedb/';
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Con
nection failure: ", Ace->error;
my $query="find SK_map";

my @skmaplist= $db->find($query);

my $id = 0;
foreach $skmap (@skmaplist) {
    $id++;
    $exprProfile = $skmap->Expr_profile;

    #find gene id
    if ($exprProfile->PCR_product) {
	$pcr = $exprProfile->PCR_product;
	if ($pcr->Microarray_results) {
	    $mr = $pcr->Microarray_results;
	    if ($mr->Gene) {
		 $gene = $mr->Gene;
		 if ($gene->Public_name) {
		     $genename = $gene->Public_name;
		 } else {
		     $genename = "N.A.";
		 }
	    } else {
		$gene = "N.A.";
		$genename = "N.A.";
	    }
	} else {
	    $gene = "N.A.";
	    $genename = "N.A.";
	}
    } else {
	$gene = "N.A.";
	$genename = "N.A.";
    }
   
    $xCord = $skmap->X_coord;
    $yCord = $skmap->Y_coord;

    if ($skmap->Mountain) {
	$mountain = $skmap->Mountain;
    } else {
	$mountain = "N.A.";
    }

    print OUT "$exprProfile\t$gene\t$genename\t$mountain\t$xCord\t$yCord\n";
}

print "$id expression profiles found.\n";

$db->close();
close (OUT);
