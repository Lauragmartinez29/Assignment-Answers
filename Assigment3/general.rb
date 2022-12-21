require './mutagenesis.rb'
require 'bio'

puts "Please be patient, this process is going to take a few minutes"
#Import the gene codes from the file
genes = Mutation.import_genes(ARGV[0])
sequence = 'cttctt' #target for mutation

#Retrieve the positions of the target sequence in the exons and add as new features
genes.each do |code|
    Mutation.get_positions(code,sequence)
    Mutation.newfeature(code, sequence)
end
#Create the report of the genes that don't contain the target sequence
Mutation.report_nomatches(ARGV[1], sequence)

all_bioseq = Mutation.all_bioseq()

#Create the GFF reports of all the genes that contain the target sequence
Mutation.relative_gff(ARGV[1], all_bioseq)
Mutation.chromosome_gff(ARGV[1], all_bioseq)

puts "The process has finished correctly. Reports have been generated"