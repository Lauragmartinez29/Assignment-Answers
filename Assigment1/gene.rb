require 'csv'
#This is the class Gene with one method.
class Gene
    #the accessor is for the genen method argument that extracts the gene name from the gene id.
    attr_accessor :geneid
    def initialize (geneid:'AT1G30950')
        @table2 = CSV.read('./gene_information.tsv', headers: true, col_sep: "\t")
        @geneid = geneid
    end
    def genen
        #Extracts the idex of the gene id introduced and uses it to give the gene name
        i = @table2['Gene_ID'].find_index(@geneid)
        return @table2['Gene_name'][i]
    end
end