require './gene.rb'
require './seedstock.rb'
require './hybridcross.rb'

testseed = Seed.new(seedid:'A348')
puts testseed.subtraction

testhybrid = Hybrid.new
puts testhybrid.chisquare