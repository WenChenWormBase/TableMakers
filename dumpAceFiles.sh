#!/bin/csh
#-------------prepare ace files for PCL file generation---------------------
setenv ACEDB /home/citace/WS/acedb/
## from Wen
/usr/local/bin/tace -tsuser 'wen' <<END_TACE
QUERY FIND Gene WBG*;
show -a -t Public_name -f GenePublicName.ace
show -a -t RNASeq_FPKM -f RNASeq_FPKM.ace
QUERY FIND Life_stage;
show -a -t Public_name -f LS_name.ace
quit
END_TACE
