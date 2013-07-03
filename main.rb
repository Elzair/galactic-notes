#!/usr/bin/env ruby

require './parser.rb'
require './vm.rb'

if __FILE__ == $0
  # First handle command line arguments
  ignore_case = false
  inputs = []
  #STDOUT.sync = true
  ARGV.each do |a|
    if a == "-i"
      ignore_case = true
    else
      begin
        file = File.open(a)
        while !file.eof
          inputs.push(file.readline.chomp)
        end
      rescue
        puts "Cannot open file: #{a}"
      ensure
        file.close()
      end
    end
  end
  STDIN.flush
  vm = VM.new
  parser = GalacticParser.new(vm, ignore_case)
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
