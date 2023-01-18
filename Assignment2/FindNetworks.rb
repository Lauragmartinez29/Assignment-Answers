require './InteractionNetwork.rb'
require './uso_general.rb'

puts "Searching correlations..."

#Load the gene codes from the file.
all_genes = InteractionNetwork.load_file(ARGV[0]) 

#Iterate through all the genes from the file to obtain their networks.
all_genes.each() do |locus_code|
    InteractionNetwork.Build_network(locus_code) 
    InteractionNetwork.Search_in_networks(locus_code, all_genes) 
end

interactions_list = InteractionNetwork.all_associated_networks()

#Create the report with the networks found from all_associated_networks.
InteractionNetwork.report(ARGV[1], interactions_list)