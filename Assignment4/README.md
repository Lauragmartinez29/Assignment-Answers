Due to the large amount of time to execute the script to find orthologs with the two proteomes, the virtual machine stop working before generating a report, so I made a subset of 16000 lines from each of the FASTA files.
The file containing Arabidopsis genes is called genes.fa, and the file containing S.pombe's proteins is protein.fa.
The original proteomes files couldn't be uploaded to github because of their size.

To execute the search_orthologs.rb script: 
ruby search_orthologs protein genes
The first argument is the name of a proteome database and the second is the name of a genome database.

The parameters stablish to select the orthologs are extracted from the paper by Ward and Moreno-Hagelsieb.

The following step to demonstrate that these genes are orthologous could be performing a cluster of othologous genes with a third specie related to Arabidopsis and S.pombe. If we select only the clusters that contain othologous genes of the 3 species, we can be more sure about their orthology. 

References

1.  Ward N, Moreno-Hagelsieb G (2014) Quickly Finding Orthologs as Reciprocal Best Hits with BLAT, LAST, and UBLAST: How Much Do We Miss?. PLOS ONE 9(7): e101850. https://doi.org/10.1371/journal.pone.0101850
2.  Trachana, K., Larsson, T.A., Powell, S., Chen, W.-H., Doerks, T., Muller, J. and Bork, P. (2011), Orthology prediction methods: A quality assessment using curated protein families. Bioessays, 33: 769-780. https://doi.org/10.1002/bies.201100062
