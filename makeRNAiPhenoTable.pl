#!/usr/bin/perl -w

use strict;
use Ace;

#my @gene;
#my @phenotype;
#my %geneName;
#my %pheName;
#my ($g, $gname, $p, $pName);

print "This script create Gene-RNAi-Phenotype table from current WS release.\n";

my $acedbpath='/home/citace/WS/acedb/';
my $tace='/usr/local/bin/tace';

print "connecting to database... ";
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;

#-----------------Build Gene - Gene Name table---------------------------
#my $query="QUERY FIND RNAi Strain = N2 OR Genotype = N2; follow Gene";

#@gene = $db->find($query);
#foreach $g (@gene) {
#        if ($g->Public_name) {
#	    $gname = $g->Public_name;
#	    $geneName{$g} = $gname;
#	} else {
#	    $geneName{$g} = "";
#	}
#}
#print scalar @gene, " genes found in database with RNAi results.\n";


#-----------------Build Phenotype - Phenotype Name table---------------------------
#$query="QUERY FIND RNAi Strain = N2 OR Genotype = N2; follow Phenotype";

#@p = $db->find($query);
#foreach $p (@phenotype) {
#        if ($p->Public_name) {
#	    $pname = $p->Public_name;
#	    $pheName{$p} = $pname;
#	} else {
#	    $pheName{$p} = "";
#	}
#}
#print scalar @phenotype, " phenotypes found in database with RNAi results.\n";


#------------------Build Expression cluster Description table ------------
my ($spe, $ref, $t, $i, $r, $pname, $all_gene, $all_phenotype, $no_phenotype);

my @tmp = ();
my @tmpName = ();

open (OUT1, ">RNAiPhenotype.csv") || die "cannot open $!\n";
print OUT1 "RNAi\tSpecies\tReference\tGene\tPhenotype Observed\tPhenotype Not Observed\n";

my $query="QUERY FIND RNAi Strain = N2 OR Genotype = N2";
#my $query="QUERY FIND RNAi WBRNAi00007523";

my @rnai = $db->find($query);
print scalar @rnai, " RNAi in N2 background found in database.\n";

foreach $r (@rnai) {

    if ($r -> Species) {
	$spe = $r -> Species;
    } else {
	$spe = "N.A.";
    }

    if ($r -> Reference) {
	@tmp =  $r -> Reference;
	$ref = join ",", @tmp;
	@tmp = ();
    } else {
	$ref = "N.A.";
    }
	
    if ($r -> Phenotype) {
	@tmp =  $r -> Phenotype;
	$i = 0;
	foreach $t (@tmp) {
	    if ($t -> Primary_name) {
		$pname = $t -> Primary_name;
		$tmpName[$i] = "$t($pname)"; 
	    } else {
		$tmpName[$i] = $t;
	    }
	    $i++;
	}	
	$all_phenotype = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$all_phenotype = "";
    }

    if ($r -> Phenotype_not_observed) {
	@tmp =  $r -> Phenotype_not_observed;
	$i = 0;
	foreach $t (@tmp) {
	    if ($t -> Primary_name) {
		$pname = $t -> Primary_name;
		$tmpName[$i] = "$t($pname)"; 
	    } else {
		$tmpName[$i] = $t;
	    }
	    $i++;
	}	
	$no_phenotype = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$no_phenotype = "";
    }

    if ($r -> Gene) {
	@tmp =  $r -> Gene;
	$i = 0;
	foreach $t (@tmp) {
	    if ($t -> Public_name) {
		$pname = $t -> Public_name;
		$tmpName[$i] = "$t($pname)"; 
	    } else {
		$tmpName[$i] = $t;
	    }
	    $i++;
	}	
	$all_gene = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$all_gene = "";
    }

    print OUT1 "$r\t$spe\t$ref\t$all_gene\t$all_phenotype\t$no_phenotype\n";
}

close (OUT1);
$db->close();
