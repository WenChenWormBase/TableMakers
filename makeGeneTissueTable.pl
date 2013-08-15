#!/usr/bin/perl -w

use strict;
use Ace;

my @gene;
my @AO;
my %geneName;
my %AOName;
my ($g, $gname, $a, $aname, $totalTissue, $totalGene, $i);

print "This script create Gene-Tissue table based on Expr_pattern data from current WS release.\n";

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


#-----------------Build Gene - Tissue table---------------------------
open (OUT1, ">GeneTissue.csv") || die "cannot open $!\n";
print OUT1 "Gene ID\tPublic Name\tTissue\n";

foreach $g (@gene) {
    $query="find Gene $g; follow Expr_pattern; follow Anatomy_term";
    @AO = $db->find($query);
    $totalTissue = @AO;
 
    next unless ($totalTissue != 0);
    
    $i = 0;
    print OUT1 "$g\t";
    if ($geneName{$g}) {
	print OUT1 "$geneName{$g}\t";
    } else {
	print OUT1 "N.A.\t";

    }
    while ($i < $totalTissue) {
	#print separator
	if ($i == 0) {
	    #do nothing
	} else {
	    print OUT1 ",";
	} 
	#done.

	$a = $AO[$i];
	if ($AOName{$a}) {
	  print OUT1 "$a($AOName{$a})";
	} else {
	  print OUT1 "$a(N.A.)"; 
	}

	$i++;
    }
    print OUT1 "\n";
}
close (OUT1);
print "Done printing Gene-Tissue table.\n";

$db->close();
