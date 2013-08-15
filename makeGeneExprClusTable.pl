#!/usr/bin/perl -w

use strict;
use Ace;

my @gene;
my @exprCluster;
my %geneName;
my ($g, $gname, $AllCluster);

print "This script create Gene-ExprCluster table from current WS release.\n";

my $acedbpath='/home/citace/WS/acedb/';
my $tace='/usr/local/bin/tace';

print "connecting to database... ";
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;

open (OUT1, ">GeneExprCluster.csv") || die "cannot open $!\n";
print OUT1 "Gene ID\tPublic Name\tExpression Cluster\n";

#-----------------Build Gene - ExprCluster table---------------------------
my $query="QUERY FIND Gene Expression_cluster";

@gene = $db->find($query);
foreach $g (@gene) {
        if ($g->Public_name) {
	    $gname = $g->Public_name;
	    $geneName{$g} = $gname;
	} else {
	    $geneName{$g} = "";
	}
	@exprCluster = $g->Expression_cluster;
	$AllCluster = join ",", @exprCluster;
	print OUT1 "$g\t$geneName{$g}\t$AllCluster\n";
}
print scalar @gene, " genes found in database with expression cluster results.\n";
close (OUT1);

#------------------Build Expression cluster Description table ------------
my ($e, $description, $spe, $ref, $tissue, $ls, $reg_mol, $reg_gene, $reg_treatment, $process, $t, $i, $pname);
#my ($t, $tissue_name, $ls_name, $mol_name, $process_name);
my @tmp;
my @tmpName;

open (OUT2, ">ExprClusterTable.csv") || die "cannot open $!\n";
print OUT2 "Name\tDescription\tSpecies\tReference\tTissue\tLife stage\tRegulated by Molecule\tRegulated by Gene\tRegulated by Treatment\tProcess\n";

$query="FIND Expression_cluster";
@exprCluster = $db->find($query);
foreach $e (@exprCluster) {

    if ($e -> Description) {
	$description = $e -> Description;
    } else {
	$description = "N.A.";
    }

    if ($e -> Species) {
	$spe = $e -> Species;
    } else {
	$spe = "N.A.";
    }

    if ($e -> Reference) {
	@tmp =  $e -> Reference;
	$ref = join ",", @tmp;
	@tmp = ();
    } else {
	$ref = "N.A.";
    }
	
    if ($e -> Regulated_by_molecule) {
	@tmp =  $e -> Regulated_by_molecule;
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
	$reg_mol = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$reg_mol = "";
    }

    if ($e -> Regulated_by_gene) {
	@tmp =  $e -> Regulated_by_gene;
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
	$reg_gene = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$reg_gene = "";
    }

    if ($e -> Regulated_by_treatment) {
	@tmp =  $e -> Regulated_by_treatment;
	$reg_treatment = join ",", @tmp;
	@tmp = ();
    } else {
	$reg_treatment = "";
    }

    if ($e -> Anatomy_term) {
	@tmp =  $e -> Anatomy_term;
	$i = 0;
	foreach $t (@tmp) {
	    if ($t -> Term) {
		$pname = $t -> Term;
		$tmpName[$i] = "$t($pname)"; 
	    } else {
		$tmpName[$i] = $t;
	    }
	    $i++;
	}	
	$tissue = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$tissue = "";
    }

    if ($e -> Life_stage) {
	@tmp =  $e -> Life_stage;
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
	$ls = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$ls = "";
    }

    if ($e -> WBProcess) {
	@tmp =  $e -> WBProcess;
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
	$process = join ",", @tmpName;
	@tmp = ();
	@tmpName = ();
    } else {
	$process = "";
    }
    
    print OUT2 "$e\t$description\t$spe\t$ref\t$tissue\t$ls\t$reg_mol\t$reg_gene\t$reg_treatment\t$process\n";
}

close (OUT2);
$db->close();
