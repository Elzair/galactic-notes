#!/usr/bin/env ruby

require './parser.rb'

if __FILE__ == $0
  STDOUT.sync = true
  handler = Parser.new
  loop do
    print "Enter Input: "
    input = gets.chomp
    handler.set(input)
    puts "You entered: " + handler.get(input).to_s
    puts handler.get_all
  end 
end
