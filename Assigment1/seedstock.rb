require 'csv'
#I create a class seed with two methods
class Seed
    #The accessor is for the argument of the second method that extracts the gene id from the seed id
    attr_accessor :seedid
    def initialize (seedid:'A334')
        @seedid = seedid
        #I import the csv table in the initialize method to use it in both subtraction and geneid methods
        @table1 = CSV.read('./seed_stock_data.tsv', headers: true, col_sep: "\t")
    end
    #The subtraction method is going to take the column of the seed grams, subtract 7g, warning if we run out of 
    #some seed and generate a new file with the new grams remaining.
    def subtraction
        newgrams = []
        #First we make a loop with the table to subtract 7 from the last element of each line and keep that number in an array
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
        newfile['Grams_Remaining'] = newgrams #Here I change the last column with the array that contains the new grams.
        #FInally I introduce the new table in a new file.
        File.open("new_stock_file.tsv", "w+") do |f|
            f.puts "#{newfile.headers[0]}\t#{newfile.headers[1]}\t#{newfile.headers[2]}\t#{newfile.headers[3]}\t#{newfile.headers[4]}\t"
            newfile.each do |line|
                f.puts "#{line[0]}\t#{line[1]}\t#{line[2]}\t#{line[3]}\t#{line[4]}" #I do this instead of "puts line" to make the tabulations.
            end
        end
    end
    def geneid
        #In this method I introduce the seed id, search its index and use it to extract the gene id.
        i = @table1['Seed_Stock'].find_index(@seedid)
        return @table1['Mutant_Gene_ID'][i]
    end
end