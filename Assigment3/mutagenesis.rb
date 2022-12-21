require 'bio'
require 'rest-client'

class Mutation

    @@all_positions = {}
    @@all_bioseq = {}
    @@not_match = []

    #Import the gene codes from the imput file
    def self.import_genes(file)
        all_genes = []
        File.foreach(file) do |code|
            all_genes.append(code.upcase.strip)
        end
        return all_genes
    end

    #Retrieve the gene coordinates for the target sequence if present and add those gene codes with their 
    #cooordinates to the @@all_positions hash. The rest of the genes are stored in a @@not_match array
    def self.get_positions(code,sequence)
        coordplus = []
        coordminus = []
        target = Bio::Sequence::NA.new(sequence)
        re = Regexp.new(target.to_re)

        address = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{code}"
        response = RestClient.get(address)
        embl = Bio::EMBL.new(response)
        embl.features.each do |feature|
            featuretype = feature.feature
            next unless featuretype == "exon"
            feature.locations.each do |l|
                exon = embl.seq[l.from..l.to]
                if l.strand == 1 && exon
                    exonpositions = exon.enum_for(:scan, re).map {Regexp.last_match.begin(0)} 
                    exonpositions.each do |positions|
                        coordplus.append("#{positions+1..positions+sequence.length}")
                    end
                elsif l.strand == -1 && exon
                    exonpositions = exon.enum_for(:scan, re).map {Regexp.last_match.begin(0)} 
                    exonpositions.each do |positions|
                        coordminus.append("complement(#{positions..positions+sequence.length-1})")
                    end
                end
                end
                end

        if coordplus.nil? && coordminus.nil? || coordplus.empty? && coordminus.empty?
            @@not_match.append("#{code}")
        else
            @@all_positions["#{code}"] = [coordplus.uniq, coordminus.uniq]
        end
    end

    def self.not_match()
        return @@not_match
    end

    #Add the positions of the target sequence as new features to the biosequences
    def self.newfeature(code, seq)
        address = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{code}"
        response = RestClient.get(address)
        embl = Bio::EMBL.new(response)
        bioseq = embl.to_biosequence
        @@all_bioseq["#{code}"] = bioseq
        if @@all_positions.include? code
            @@all_positions["#{code}"].each do |positions|
                unless [nil].include?(positions)
                positions.each do |sites|
                    feature = Bio::Feature.new('mutation_site', sites)
                    feature.append(Bio::Feature::Qualifier.new('motif', seq))
                    feature.append(Bio::Feature::Qualifier.new('function','insertion site'))
                    if sites.include? "complement"
                        feature.append(Bio::Feature::Qualifier.new('strand', '-'))
                    else
                        feature.append(Bio::Feature::Qualifier.new('strand', '+'))
                    end
                    bioseq.features << feature
                end
                end
            end
            
        end
    end 

    #Return all the biosequences that contain the target sequence
    def self.all_bioseq()
        return @@all_bioseq
    end

    #Create the GFF report of the new features generated for the biosequences with coordinates relative to each gene
    def self.relative_gff(file, all_bioseq)
        File.open("#{file}_relative.gff3", 'w+') do |file|
            file.puts "##gff-version 3"
            @@all_bioseq.each do |bioseq|
                bioseq[1].features.each do |feature|
                    if feature.feature == 'mutation_site' 
                        chromosome = bioseq[1].primary_accession.split(":")[2]
                        position = feature.position
                        if position.include? "complement"
                            position = position.split("(")[1].split(")")[0]
                            positionfrom = position.split("..")[0]
                            positionto = position.split("..")[1]
                        else
                            positionfrom = position.split("..")[0]
                            positionto = position.split("..")[1]
                        end
                        file.puts "chr#{chromosome}\tLaura\texon_region\t#{positionfrom}\t#{positionto}\t.\t#{feature.assoc['strand']}\t.\tID=#{bioseq[0]};Name=Mutation_target_#{bioseq[0]}"
                    end
                end
            end
        end
    end
    
    #Create the GFF report of the new features generated for the biosequences with coordinates relative to the chromosomes
    def self.chromosome_gff(file, all_bioseq)
        File.open("#{file}_chr.gff3", 'w+') do |file|
            file.puts "##gff-version 3"
            @@all_bioseq.each do |bioseq|
                bioseq[1].features.each do |feature|
                    if feature.feature == 'mutation_site' 
                        chromosome = bioseq[1].primary_accession.split(":")[2]
                        position = feature.position
                        absolutepos = bioseq[1].primary_accession.split(":")[3].to_i
                        if position.include? "complement"
                            position = position.split("(")[1].split(")")[0]
                            positionfrom = position.split("..")[0].to_i
                            positionto = position.split("..")[1].to_i
                        else
                            positionfrom = position.split("..")[0].to_i
                            positionto = position.split("..")[1].to_i
                        end
                        file.puts "chr#{chromosome}\tLaura\texon_region\t#{absolutepos+positionfrom}\t#{absolutepos+positionto}\t.\t#{feature.assoc['strand']}\t.\tID=#{bioseq[0]};Name=Mutation_target_#{bioseq[0]}"
                    end
                end
            end
        end
    end

    #Create a report containing the gene codes for the genes that don't contain the target sequence
    def self.report_nomatches(file, sequence)
        File.open("#{file}_no_matches.txt", 'w+') do |file|
            file.puts "This genes don't contain the sequence #{sequence}"
            file.puts @@not_match
        end
    end
end


