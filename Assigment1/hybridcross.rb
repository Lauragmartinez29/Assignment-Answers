require 'csv'
require './seedstock.rb'
require './gene.rb'

class Hybrid
    def initialize
        @table3 = CSV.read('./cross_data.tsv', headers: true, col_sep: "\t")
    end
    def chisquare
        linked = []
        @table3.each do |line|
            owild = line[2].to_f
            op1 = line[3].to_f
            op2 = line[4].to_f
            op1p2 = line[5].to_f
            total = owild + op1 + op2 + op1p2
            ewild = total*9/16
            ep1 = total*3/16
            ep2 = total*3/16
            ep1p2 = total*1/16
            chi = ((owild-ewild)**2/ewild + (op1-ep1)**2/ep1 + (op2-ep2)**2/ep2 + (op1p2-ep1p2)**2/ep1p2)
            next if chi < 7.815              
            geneid1 = Seed.new(seedid:line[0])
            geneid2 = Seed.new(seedid:line[1])
            genename1 = Gene.new(geneid:geneid1.geneid)
            genename2 = Gene.new(geneid:geneid2.geneid)
            gn1 = genename1.genen
            gn2 = genename2.genen
            puts "Recording: #{gn1} is genetically linked to #{gn2} with chisquare score #{chi}"
            linked.append([gn1,gn2])
        puts "\nFinal Report:"
        for i in linked do
        puts "#{i[0]} is linked to #{i[1]}\n#{i[1]} is linked to #{i[0]}"
        end
        end
    end
end