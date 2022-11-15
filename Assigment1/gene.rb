require 'csv'

class Gene
    attr_accessor :geneid
    def initialize (geneid:'AT1G30950')
        @table2 = CSV.read('./gene_information.tsv', headers: true, col_sep: "\t")
        @geneid = geneid
    end
    def genen
        i = @table2['Gene_ID'].find_index(@geneid)
        return @table2['Gene_name'][i]
    end
end