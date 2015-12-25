#!/usr/bin/perl -w

use strict;

print "This script create Gene Name table from current WS release.\n";

#-------------- ------------
my ($line, $g, $pub_name, $seq_name, $uniprot, $treefam, $refSeqRNA, $refSeqProtein);
my @tmp;

open (IN, "/home/wen/Tables/GeneIdentity/WBGeneIdentity.ace") || die "cannot open WBGeneIdentity.ace!\n";
open (OUT, ">WBGeneName.csv") || die "cannot open $!\n";
#open (IN, "/home/wen/Tables/GeneIdentity/test.ace") || die "cannot open test.ace!\n";
#open (OUT, ">testWBGeneName.csv") || die "cannot open $!\n";

print OUT "Gene\tPublic Name\tSequence Name\tUniprot\tTreeFam\tRefSeq_mRNA\tRefSeq_protein\n";

$line = <IN>;
while ($line =<IN>) {
    chomp($line);
    if ($line =~ /^Gene/) {
	@tmp = split '"', $line;
	$g = $tmp[1];
	$pub_name = "N.A.";
	$seq_name = "N.A.";
	$uniprot = "N.A.";
	$treefam = "N.A.";
	$refSeqRNA = "N.A.";
	$refSeqProtein = "N.A.";
    } elsif ($line =~ /^Sequence_name/) {
	@tmp = split '"', $line;
	$seq_name = $tmp[1];
    } elsif ($line =~ /^Public_name/) {
	@tmp = split '"', $line;
	$pub_name = $tmp[1];
    }  elsif ($line =~ /UniProt/) {
	@tmp = split '"', $line;
	if ($uniprot eq "N.A.") {
	    $uniprot = $tmp[5];
	} else {
	    $uniprot = join ",",  $uniprot, $tmp[5];
	}
    }  elsif ($line =~ /TREEFAM/) {
	@tmp = split '"', $line;
	$treefam = $tmp[5];
    }  elsif (($line =~ /RefSeq/) && ($line =~ /mRNA/)) {
	@tmp = split '"', $line;
	if ($refSeqRNA eq "N.A.") {
	    $refSeqRNA = $tmp[5];
	} else {
	    $refSeqRNA = join ",",  $refSeqRNA, $tmp[5];
	}
    }  elsif (($line =~ /RefSeq/) && ($line =~ /protein/)) {
	@tmp = split '"', $line;
	if ($refSeqProtein eq "N.A.") {
	    $refSeqProtein = $tmp[5];
	} else {
	    $refSeqProtein = join ",",  $refSeqProtein, $tmp[5];
	}
    } elsif  ($line eq "") {
	print OUT "$g\t$pub_name\t$seq_name\t$uniprot\t$treefam\t$refSeqRNA\t$refSeqProtein\n";
    }
}
close(IN);
close(OUT);
