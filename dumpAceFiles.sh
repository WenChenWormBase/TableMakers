#!/bin/csh
#-------------prepare ace files for PCL file generation---------------------
setenv ACEDB /home/citace/WS/acedb/
## from Wen
/usr/local/bin/tace -tsuser 'wen' <<END_TACE
QUERY FIND Gene WBGene*
show -a -t Identity -f /home/wen/Tables/GeneIdentity/WBGeneIdentity.ace
quit
END_TACE
