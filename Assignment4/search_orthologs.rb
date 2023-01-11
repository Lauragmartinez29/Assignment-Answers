#This script finds the putative orthologs between a FASTA file containing proteins and a FASTA file of genes.

require 'bio'

#Index the genome database file
unless File.exists?("#{ARGV[1]}.nhr") and File.exists?("#{ARGV[1]}.nin") and File.exists?("#{ARGV[1]}.nsq")
    system("makeblastdb -in #{ARGV[1]}.fa -dbtype 'nucl' -out #{ARGV[1]} &> /dev/null")
end

#Prepare the BLAST with the genome database 
factory = Bio::Blast.local('tblastn', "#{ARGV[1]}")

$stderr.puts "Performing the first BLAST... "

#Perform a tblastn of the proteome query and keep in a report hash the genes that match the selected parameters 
report = {}
Bio::FlatFile.auto("#{ARGV[0]}.fa").each_entry do |query|
    blast = factory.query(query)
    if blast.hits[0] and blast.hits[0].evalue and blast.hits[0].identity and blast.hits[0].overlap and blast.hits[0].query_len
        identity_percentage = (blast.hits[0].identity.to_f/blast.hits[0].overlap.to_f)*100
        coverage_percentage = ((blast.hits[0].query_end.to_f-blast.hits[0].query_start.to_f)/blast.hits[0].query_len.to_f)*100
        if blast.hits[0].evalue <= 1e-6 and identity_percentage >= 25 and coverage_percentage >= 50 
            tid = blast.hits[0].definition.split("|")[0].strip 
            report[query.entry_id] = tid
        end
    end
end

#Idex the proteome database
unless File.exists?("#{ARGV[0]}.nhr") and File.exists?("#{ARGV[0]}.nin") and File.exists?("#{ARGV[0]}.nsq")
    system("makeblastdb -in #{ARGV[0]}.fa -dbtype 'prot' -out #{ARGV[0]} &> /dev/null")
end

#Prepare the second BLAST with the proteome database
factory2 = Bio::Blast.local('blastx', "#{ARGV[0]}")

$stderr.puts "Performing the second BLAST ... "

##Perform a blastx of the genome query and keep in a report2 hash the proteins that match the selected parameters 
report2 = {}
Bio::FlatFile.auto("#{ARGV[1]}.fa").each_entry do |query|
    blast = factory2.query(query)
    if blast.hits[0] and blast.hits[0].evalue and blast.hits[0].identity and blast.hits[0].overlap and blast.hits[0].query_len
        identity_percentage = (blast.hits[0].identity.to_f/blast.hits[0].overlap.to_f)*100
        coverage_percentage = ((blast.hits[0].query_end.to_f-blast.hits[0].query_start.to_f)/blast.hits[0].query_len.to_f)*100
        if blast.hits[0].evalue <= 1e-6 and identity_percentage >= 25 and coverage_percentage >= 50 
            tid = blast.hits[0].definition.split("|")[0].strip
            report2[tid] = query.entry_id
        end
    end
end

#Compare the elements in report and report2 and keep in the othologs hash those who have in common.
orthologs = {}
report.each do |key, value|
    if report2[key]==value
        orthologs.store(key, value)
    end
end

#Write a report 
array_orthologs = orthologs.to_a
File.open("orthologs.txt", 'w+') do |f|
    f.puts "Report: Use of BLAST to  Discover putative Orthologs\n"
    f.puts "There are #{array_orthologs.length} othologs candidates\n"
    array_orthologs.each do |entry|
        f.puts "#{entry[1]} - #{entry[0]}"
    end
end
