#!/usr/bin/perl -w

use strict;
use Ace;

my @mrExp;
my @tmp;
my @stuff;
my @remark;
my %PaperGDS;
my %PaperPMID;
my %PaperGPL;
my %mrExpGSM;
my ($line, $TotalColumns, $r, $m, $gsm, $gse, $paper, $pmid, $p, $platform, $gpl, $condition, $database, $condA, $aoTerm, $lsTerm);

print "This script create Microarray_experiment table from current WS release.\n";

my $acedbpath='/home/citace/WS/acedb/';
#my $acedbpath='/home/citace/citace/';
my $tace='/usr/local/bin/tace';

print "connecting to database... ";
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;

open (OUT1, ">MrExpTable.csv") || die "cannot open $!\n";
print OUT1 "Paper\tPMID\tGSE\tPlatform\tExperiment\tGSM\tTissue\tLife_stage\n";

#---------------Get GEO info -----------------------------

open (GEOT, "/home/wen/LargeDataSets/Microarray/CurationLog/FindID/MAPaperGSETable.txt") || die "can't open $!";
while($line = <GEOT>){
    chomp ($line);
    @tmp=split("\t", $line);
    $TotalColumns = @tmp;
    #print "$TotalColumns\n";
    next unless ($TotalColumns == 5);
    $PaperGDS{$tmp[1]} = $tmp[4];
    $PaperGPL{$tmp[1]} = $tmp[3];
    #$PaperPMID{$tmp[1]} = $tmp[2];
    #print "$tmp[1] $PaperGDS{$tmp[1]} $PaperGPL{$tmp[1]}\n";
}
close (GEOT);

#---------Build PMID-WBPaper ID hash --------------------
my $query="query find Paper Database = MEDLINE";
my @paperList=$db->find($query);
my $totalPaper = @paperList;

foreach $paper (@paperList) {
        $database = $paper->get('Database', 2);
	if ($database eq "PMID") {
	    $pmid=$paper->get('Database', 3);
	    $PaperPMID{$paper} = $pmid;
	} 
}
print "$totalPaper WormBase papers found with medline accession number.\n"; 

#------------Build AO Name hash-------------------------------------------
$query="QUERY FIND Condition Tissue; follow Tissue";
my ($a, $aname);
my %AOName;
my @AO = $db->find($query);
foreach $a (@AO) {
        if ($a->Term) {
	    $aname = $a->Term;
	    $AOName{$a} = $aname;
	}
}
print scalar @AO, " Anatomy_term involved in Microarray.\n";
#------------------Done--------------------------------------------------


#------------Build Life stage Name hash-------------------------------------------
$query="QUERY FIND Condition Life_stage; follow Life_stage";
my ($ls, $lsname);
my %LSName;
my @LS = $db->find($query);
foreach $ls (@LS) {
        if ($ls->Public_name) {
	    $lsname = $ls->Public_name;
	    $LSName{$ls} = $lsname;
	}
}
print scalar @LS, " Life_stage involved in Microarray.\n";
#------------------Done--------------------------------------------------


#-----------------Build Microarray Experiment table---------------------------
$query="find Microarray_experiment";

@mrExp = $db->find($query);
foreach $m (@mrExp) {

        if ($m->Reference) {
	    @tmp = $m->Reference;
	    $paper = $tmp[0];
	    @tmp = ();
	    
	    if ($PaperPMID{$paper}) {
		$pmid = $PaperPMID{$paper};
	    } else {
		$pmid = "N.A.";
	    }

	    if ($PaperGDS{$paper}) {
		$gse = $PaperGDS{$paper};
	    } else {
		$gse = "N.A.";
	    }


	    if ($PaperGPL{$paper}) {
		$gpl = $PaperGPL{$paper};	
	    } else {
		$gpl = "GPL?";
	    }	    
	    if ($m->Microarray) {
	       $p = $m->Microarray;
	       if ($p =~ /^GPL/) {
		   $gpl = $p;
		   $platform = $p->Chip_info;  
	       } else {
		   $platform = $p;
	       }
	    }	    
	    #$platform = "$gpl($platform)";


	} else { # if there is no reference
	    $paper = "N.A.";
	    $pmid = "N.A.";
	    $gse = "N.A.";
	    if ($m->Microarray) {
		$platform = $m->Microarray;
	    } else {
		$platform = "N.A.";
	    }
	}

	#get GSM record
	$gsm = "N.A.";
	if ($m->Remark) {
	    @remark = $m->Remark;
	} 
	foreach $r (@remark) {
	    if ($r =~ /GEO record/) {
		$gsm = $r;
		#($stuff[0], $stuff[1]) = split '"', $r;
		#($stuff[3], $stuff[4]) = split 'GSM', $stuff[1];
		#$gsm = "GSM$stuff[3]";
		#print "$gsm\n";
	    }
	}

	#get condition objects
	if ($m->Microarray_sample) {
	    $condition = $m->Microarray_sample;
	} elsif ($m->Sample_A) {
	    $condition = $m->Sample_A;
	} else {
	    $condition = "N.A.";
	    $aoTerm = "N.A.";
	    $lsTerm = "N.A.";
	}

	next unless ($condition ne "N.A."); 
	if ($condition->Tissue) {
		@tmp = $condition->Tissue;
		
		foreach (@tmp) {
		    if ($AOName{$_}) {
			$aname = $AOName{$_};
			$_ = "$_($aname)";
		    }
		}

		$aoTerm = join ",", @tmp;
		#print "$paper - $aoTerm\n";
		@tmp = ();
	} else {
		$aoTerm = "N.A.";
	}

	if ($condition -> Life_stage) {
		@tmp = $condition -> Life_stage;

		foreach (@tmp) {
		    if ($LSName{$_}) {
			$lsname = $LSName{$_};
			$_ = "$_($lsname)";
		    }
		}

		$lsTerm = join ",", @tmp;
		@tmp = ();
	} else {
		$lsTerm = "N.A.";
	}

	#print the results
	print OUT1 "$paper\t$pmid\t$gse\t$gpl($platform)\t$m\t$gsm\t$aoTerm\t$lsTerm\n";

}

print scalar @mrExp, " microarray experiments found in database.\n";

close (OUT1);
$db->close();
