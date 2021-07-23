#!/usr/bin/perl
use strict;


#-------------------Type out the purpose of the script-------------
print "This program create a table of FPKM values of modENCODE RNASeq.\n";
print "Input file: \n";
print "Input file: \n";


my ($line, $g, $gname, $ls, $lsname, $analysis, $sra, $fpkm);
my @tmp;


#------ Get Gene names  -------------------------
my %gName;
open (GN, "GenePublicName.ace") || die "can't open GenePublicName.ace!";
while ($line=<GN>) {
    @tmp = ();
    if ($line =~ /^Gene/) {
	@tmp = split '"', $line;
	$g = $tmp[1];
    } elsif ($line =~ /^Public_name/) {
	@tmp = split '"', $line;
	$gname = $tmp[1];
	$gName{$g} = $gname;
    }
}
close (GN);
#---- Done-------------------

#------ Get Life Stage names  -------------------------
my %lsName;
open (LS, "LS_name.ace") || die "can't open LS_name.ace!";
while ($line=<LS>) {
    @tmp = ();
    if ($line =~ /^Life_stage/) {
	@tmp = split '"', $line;
	$ls = $tmp[1];
    } elsif ($line =~ /^Public_name/) {
	@tmp = split '"', $line;
	$lsname = $tmp[1];
	$lsName{$ls} = $lsname;
    }
}
close (LS);
#---- Done-------------------

open (IN, "RNASeq_FPKM.ace") || die "can't open RNASeq_FPKM.ace!";
open (OUT, ">modENCODE_FPKM.csv") || die "cannot open modENCODE_FPKM.csv!\n";
print OUT "Gene ID\tGene Name\tLife Stage ID\tLife Stage\tFPKM\tAnalysis\n";

$line = <IN>;
while ($line =<IN>) {
    chomp($line);
     @tmp = ();  
    if ($line =~ /^Gene/) {
	@tmp = split '"', $line;
	$g = $tmp[1];
    } elsif ($line =~ /^RNASeq_FPKM/) {
	@tmp = split /\s+/, $line;
	$fpkm = $tmp[2];
	@tmp = ();
	@tmp = split '"', $line;
	$ls = $tmp[1];
	$analysis = $tmp[3];
	#@tmp = ();
	#@tmp = split '\.', $analysis;
	#$sra = $tmp[7];
	#print OUT "$g\t$ls\t$fpkm\t$sra\n";

	$gname = "N.A.";
	$lsname = "N.A.";
	if ($gName{$g}) {
	    $gname = $gName{$g};
	}
	if ($lsName{$ls}) {
	    $lsname = $lsName{$ls};
        }
	print OUT "$g\t$gname\t$ls\t$lsname\t$fpkm\t$analysis\n";
    } 
}
close (IN);
close (OUT);
print "Done.\n";
