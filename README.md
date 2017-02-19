# RH_expression

Analysis of RH expression data
1) Reads were clipped to remove adaptors and low quality bases with clip.pl
2) reads were aligned to HG38 with STAR two-step (star.step1.pl)
	ensembl version 87 gene models were used as a guide.
3) count files were generated with dexseq.count.pl
	this program calls dexseq.count.py from the dexseq package, which generates per exon count files. ensembl gene models version 87 were used
	
Next steps -- R/Dexseq see bioconductor vignette

