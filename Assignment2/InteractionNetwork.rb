#This class is able to find the interaction gene networks in a txt file.

require 'rest-client'
require 'set'

class InteractionNetwork

    attr_accessor :gene_id
    attr_accessor :linked_genes
    attr_accessor :networks
    attr_accessor :all_relations
    attr_accessor :associated_networks

    @@all_genes = {}
    @@all_networks = {}
    @@all_associated_networks = []
    @@current_locus
    @@locus_level1

    def initialize(params = {})
        @gene_id = params.fetch(:gene_id, nil)
        @linked_genes = params.fetch(:linked_genes, [])
        @networks = params.fetch(:networks, [])
        @associated_networks = params.fetch(:associated_networks, Array.new)
        @all_relations = params.fetch(:all_relations, Hash.new)
    end

    #This method loads the file of gene codes and returns an array with all of them.
    def self.load_file(file)
        all_locus = []
        File.foreach(file) do |locus_code|
            locus_code = locus_code.strip().upcase()
            all_locus << locus_code
        end
        return all_locus
    end

    #This method takes one gene code, searches in psiquic for interactions, takes the gene codes of the genes that appear with an score and specie filter and introduces them in the @@all_genes hash.
    def self.find_interactions(locus_code)
        interact_with = []
        address = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{locus_code}"
        response = RestClient::Request.execute(method: :get, url: address)
        response.split("\n").each do |record|
            genes = record.scan(/(A[Tt]\d[Gg]\d\d\d\d\d)/)
            mi_score = record.match(/i\w+-\w+:(0\.\d+?)/)
            if genes[1] && genes[1][0].upcase != locus_code && mi_score[1].to_f >= 0.5 && record.split("\t")[9].include?("3702") && record.split("\t")[10].include?("3702")
                interact_with.append("#{genes[1][0].upcase}")
            elsif genes[0][0].upcase != locus_code && mi_score[1].to_f >= 0.5 && record.split("\t")[9].include?("3702") && record.split("\t")[10].include?("3702")
                interact_with.append("#{genes[0][0].upcase}")
            end
        end
        @@all_genes["#{locus_code}"] = InteractionNetwork.new(:gene_id => locus_code, :linked_genes => interact_with)
        return @@all_genes["#{locus_code}"]
    end

    #This method uses the find_interactions method to iterate through the network searching for gene interactions.
    def self.Build_network(locus_code, number_of_iterations = 4)
        interactors = InteractionNetwork.find_interactions(locus_code).linked_genes.uniq 
        if interactors.empty? then return end

        if number_of_iterations == 4
            @@all_networks["#{locus_code}"] = InteractionNetwork.new(:gene_id => locus_code,  :all_relations => interactors.each_with_object({}).to_h)
            @@current_locus = locus_code
        elsif number_of_iterations == 3
            @@all_networks["#{@@current_locus}"].all_relations["#{locus_code}"] = interactors.each_with_object({}).to_h
            @@locus_level1 = locus_code
        elsif number_of_iterations == 2
              @@all_networks["#{@@current_locus}"].all_relations["#{@@locus_level1}"]["#{locus_code}"] = interactors
             return
        end
        interactors.each {|each_interactor| self.Build_network(each_interactor, number_of_iterations - 1)}
    end

    #This method checks if the found networks in the obtained hash appear in the file of gene codes and if so, it introduces them in an array and calls the Simplify_list method with it.
    def self.Search_in_networks(locus_code, genes_to_match)
        my_networks = []
        genes_to_match.delete("#{locus_code}")
        if  @@all_networks["#{locus_code}"]
            @@all_networks["#{locus_code}"].all_relations.each do |interactors2|
                interactors2[1].each do |interactors3|
                    interactors3.each do |interactors4|
                        if genes_to_match.include?(interactors4)
                            my_networks << [locus_code, interactors2[0], interactors3[0], interactors4]
                        elsif genes_to_match.include?(interactors3[0])
                            my_networks << [locus_code, interactors2[0], interactors3[0]]
                        elsif genes_to_match.include?(interactors2[0])
                            my_networks << [locus_code, interactors2[0]]
                        end
                    end
                end
            end
        end
        unique = self.Simplify_list(my_networks)
        if unique.any? then unique.each {|each_one| @@all_networks["#{locus_code}"].associated_networks << each_one} end
        if unique.any? then unique.each {|each_one| @@all_associated_networks << each_one} end
    end

    #This method is a control to delete the networks that are subsets of other ones, its aim is to simplify the array of networks.
    def self.Simplify_list(my_networks)
        unique = my_networks.uniq
        unique.each() do |network1|
            unique.each() do |network2|
                set1 = network1.to_set
                set2 = network2.to_set
                if set2.subset?(set1) && network1.any? && network2.any? && network1.length > network2.length
                    unique.delete(network2)
                elsif set2.subset?(set1) && network1.any? && network2.any? && network1.length < network2.length
                    unique.delete(network1)
                end
            end
        end
        unique.each_with_index{|each, i| unique[i] = each.chunk(&:itself).map(&:first)}
        return unique
    end

    #This method allows to access the genes that interact with the gene of the argument.
    def self.find_genes(locus_code)
        return @@all_genes["#{locus_code}"]
    end

    #This method returns a Hash of all InteractionNetwork objects
    def self.all_networks()
        return @@all_networks
    end

    #This method returns a given InteractionNetwork object when asked for an ID
    def self.find_networks(locus_code)
        return @@all_networks["#{locus_code}"]
    end

    #This methodeturns a list of all found associated networks.
    def self.all_associated_networks()
        return self.Simplify_list(@@all_associated_networks)
    end

    #This method writes a txt report with the networks found and their go and kegg terms.
    def self.report(file_argv, interactions_list)
        report = File.open(file_argv, 'w')
        report.puts("There are #{interactions_list.length} networks.\n")
        interactions_list.each_with_index() do |each_network, index|
            report.puts("\n\nNetwork #{index+1}:")
            report.puts("#{each_network.join(" - ")}\n")
            all_go_terms = []
            all_kegg_terms = []
            each_network.each() do |gene|
                Annotations.Annotate_Go(gene).each{|go_term| all_go_terms << go_term}
                Annotations.Annotate_Kegg(gene).each{|kegg_term| all_kegg_terms << kegg_term}
            end
            report.puts("\nThis network is associated with the following GO terms:")
            all_go_terms.uniq.each{|go| report.puts(" - GO:#{go[0]} - #{go[1]}")}
            report.puts("\n\n")
            report.puts("This network is associated with the following KEGG Pathways:")
            all_kegg_terms.uniq.each{|kegg| report.puts(" - Kegg ID:#{kegg[0]} - #{kegg[1]}")}
        end
    end
end
