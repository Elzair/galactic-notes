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
    begin
      parser.parse_input(input)
    rescue ParseError => e
      puts e.message
    end
  end 
end
