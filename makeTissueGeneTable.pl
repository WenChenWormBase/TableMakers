#!/usr/bin/perl -w

use strict;
use Ace;

my @gene;
my @AO;
my %geneName;
my %AOName;
my ($g, $gname, $a, $aname, $totalGene, $i);

print "This script create Tissue -- Gene table based on Expr_pattern data from current WS release.\n";

my $acedbpath='/home/citace/WS/acedb/';
my $tace='/usr/local/bin/tace';

print "connecting to database... ";
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;

#------------Build Gene Name hash------------------------------------- 
my $query="QUERY FIND Expr_pattern Anatomy_term = *; follow Gene";
@gene = $db->find($query);
foreach $g (@gene) {
        if ($g->Public_name) {
	    $gname = $g->Public_name;
	    $geneName{$g} = $gname;
	}
}
print scalar @gene, " genes found in database with expression pattern results.\n";
#--------------Done ---------------------------------------------------


#------------Build AO Name hash-------------------------------------------
$query="QUERY FIND Anatomy_term Expr_pattern = *";
@AO = $db->find($query);
foreach $a (@AO) {
        if ($a->Term) {
	    $aname = $a->Term;
	    $AOName{$a} = $aname;
	}
}
print scalar @AO, " Anatomy_term found in database with expression pattern results.\n";
#------------------Done--------------------------------------------------


#-----------------Build Tissue - Gene table---------------------------
open (OUT, ">TissueGene.csv") || die "cannot open $!\n";
print OUT "Anatomy_term\tAnatomy Name\tGene Name(ID)\n";

foreach $a (@AO) {
    $query="find Anatomy_term \"$a\"; follow Expr_pattern; follow Gene";
    #print "$query\n";
    @gene = $db->find($query);
    $totalGene = @gene;
 
    next unless ($totalGene != 0);
    
    print OUT "$a\t";
    if ($AOName{$a}) {
	print OUT "$AOName{$a}\t";
    } else {
	print OUT "N.A.\t";

    }

    $i = 0;
    while ($i < $totalGene) {
	#print separator
	if ($i == 0) {
	    #do nothing
	} else {
	    print OUT ",";
	} 
	#done.

	$g = $gene[$i];
	if ($geneName{$g}) {
	  print OUT "$g($geneName{$g})";
	} else {
	  print OUT "$g(N.A.)"; 
	}

	$i++;
    }
    print OUT "\n";
}

close (OUT);
$db->close();
