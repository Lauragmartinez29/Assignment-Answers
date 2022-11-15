require 'csv'

class Seed
    attr_accessor :seedid
    def initialize (seedid:'A334')
        @seedid = seedid
        @table1 = CSV.read('./seed_stock_data.tsv', headers: true, col_sep: "\t")
    end
    def subtraction
        newgrams = []
        for line in @table1 do
            num = (line[-1].to_i)-7
            if num > 0
                newgrams.append(num)
            else
                num = 0 
                newgrams.append(num)
                puts "WARNING: we have run out of Seed Stock #{line[0]}"
            end
        end
        newfile = @table1.clone
        newfile['Grams_Remaining'] = newgrams
        File.open("new_stock_file.tsv", "w+") do |f|
            f.puts "#{newfile.headers[0]}\t#{newfile.headers[1]}\t#{newfile.headers[2]}\t#{newfile.headers[3]}\t#{newfile.headers[4]}\t"
            newfile.each do |line|
                f.puts "#{line[0]}\t#{line[1]}\t#{line[2]}\t#{line[3]}\t#{line[4]}"
            end
        end
    end
    def geneid
        @table1 = CSV.read('./seed_stock_data.tsv', headers: true, col_sep: "\t")
        i = @table1['Seed_Stock'].find_index(@seedid)
        return @table1['Mutant_Gene_ID'][i]
    end
end