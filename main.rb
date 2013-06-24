#!/usr/bin/env ruby

require './parser.rb'
require './vm.rb'

if __FILE__ == $0
  STDOUT.sync = true
  vm = VM.new
  parser = GalacticParser.new(vm)
  loop do
    print "Enter Input: "
    input = gets.chomp
    parser.parse_input(input)
    #handler.set(input)
    #puts "You entered: " + handler.get(input).to_s
    #puts handler.get_all
  end 
end
