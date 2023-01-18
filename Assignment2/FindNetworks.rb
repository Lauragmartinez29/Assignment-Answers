require './InteractionNetwork.rb'
require './uso_general.rb'

puts "Searching correlations..."

all_genes = InteractionNetwork.load_table(ARGV[0]) 

all_genes.each() do |locus_code|
    InteractionNetwork.Build_network(locus_code) 
    InteractionNetwork.Search_in_networks(locus_code, all_genes) 
end

interactions_list = InteractionNetwork.all_associated_networks()
InteractionNetwork.report(ARGV[1], interactions_list)