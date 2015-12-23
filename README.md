1. createTopoMapTable.pl     
Stuart Kim Topo Map (mountain) data

TopoMap.csv

2. makeGeneTissueTable.pl
Genes with their tissue distribution based on GFP, immunostaining and in situ hybridization

GeneTissue.csv

3. makeTissueGeneTable.pl
Tissues with gene expression based on GFP, immunostaining and in situ hybridization

TissueGene.csv

4. makeGeneExprClusTable.pl  
All expression clusters based on chronogram and microarray results, and Expression clusters for each gene. Dead genes that are merged into another gene. 

ExprClusterTable.csv
GeneExprCluster.csv
DeadGeneList.csv

5. makeMrExpTable.pl
Microarray Experiment Table, with Gene Expression Omnibus IDs, Tissue and Life stage information

AnatomyTable.csv  
LifeStageTable.csv
MrExpTable.csv

6. makeRNAiPhenoTable.pl
RNAi phenotype table, with Species, Gene name, Observed_Phenotype and Not_observed-phenotype  

RNAiPhenotype.csv

7. dumpAceFiles.sh
This script dump out Identify tag of all WBGene* Gene objects. The result ace file WBGeneIdentity.ace under /home/wen/Tables/GeneIdentity/ is required for the next script makeGeneNameTable_from_file.pl to run. 

8. makeGeneNameTable_from_file.pl
This script takes /home/wen/Tables/GeneIdentity/WBGeneIdentity.ace file and create a table listing Public Name, Sequence Name, Uniprot, TreeFam, RefSeq_mRNA, RefSeq_protein IDs.
 
WBGeneName.csv

