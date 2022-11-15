require './gene.rb'
require './seedstock.rb'
require './hybridcross.rb'
#Creates a Seed object and puts it to perform the subtraction method
testseed = Seed.new(seedid:'A348')
puts testseed.subtraction
#Creates a Hybrid object to print the linked genes.
testhybrid = Hybrid.new
puts testhybrid.chisquare