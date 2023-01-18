#This is the class that searches for the go and kegg terms related with the genes that appear in the interaction networks.

require 'json'
require 'rest-client'
require './InteractionNetwork.rb'

class Annotations

    attr_accessor :gene_id
    attr_accessor :gene_object
    attr_accessor :interactions_object
    attr_accessor :kegg_terms
    attr_accessor :go_terms

    @@all_anotations = {}

    def initialize(params = {})
        @gene_id = params.fetch(:gene_id, nil)
        @gene_object = InteractionNetwork.find_genes(@gene_id)
            unless @gene_object.is_a?(InteractionNetwork) then 
                @gene_object = nil 
            end
        @interactions_object = InteractionNetwork.find_networks(@interactions_object)
            unless @interactions_object.is_a?(InteractionNetwork) then 
                @interactions_object = nil 
            end
        @kegg_terms = params.fetch(:kegg_terms, Hash.new)
        @go_terms = params.fetch(:go_terms, Hash.new)

    end

    #This method finds the go terms using togows with a given gene code.
    def self.Annotate_Go(locus_code)
        go_terms = {}
        address = "http://togows.dbcls.jp/entry/uniprot/#{locus_code}/dr.json"
        response = RestClient::Request.execute(method: :get, url: address)
        data = JSON.parse(response.body)[0]
        data["GO"].each do |go|
            if go[1] =~ /P:/ 
                go_terms["#{go[0]}".delete("GO:")] = go[1].delete("P:") 
            end
        end
        return go_terms
    end

    #This method finds the kegg terms using togows with a given gene code.
    def self.Annotate_Kegg(locus_code)
        address = "http://togows.org/entry/kegg-genes/ath:#{locus_code}/pathways.json"
        response = RestClient::Request.execute(method: :get, url: address)
        data = JSON.parse(response.body)[0] 
        return data
    end

    #This method annotates the given given code using the Annotate_Go and Annotate_Kegg methods from this class.
    def self.Annotate_Gene(locus_code)
        go_terms = self.Annotate_Go(locus_code)
        kegg_terms = self.Annotate_Kegg(locus_code)
        object = Annotations.new(:gene_id => locus_code.upcase, :kegg_terms => kegg_terms, :go_terms => go_terms, :gene_object => locus_code.upcase, :interactions_object => locus_code.upcase)
        p object
        return object
    end
end