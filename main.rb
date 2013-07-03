#!/usr/bin/env ruby

require './parser.rb'
require './vm.rb'

if __FILE__ == $0
  # First handle command line arguments
  ignore_case = false
  options = {}
  inputs = []
  ARGV.each do |a|
    puts "Argument: #{a}"
    case a
    when "-i"
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
  # Flush STDIN to prevent input from spilling over into main loop
  STDIN.flush
  vm = VM.new
  parser = GalacticParser.new(vm, ignore_case)
  # Process input files
  inputs.each do |inp|
    STDOUT.puts "Enter Input: #{inp}"
    begin
      parser.parse_input(inp)
    rescue ParseError => e
      STDERR.puts e.message
    end
  end
  # Enter main input loop
  loop do
    STDOUT.print "Enter Input: "
    input = STDIN.gets.chomp
    begin
      parser.parse_input(input)
    rescue ParseError => e
      STDERR.puts e.message
    end
  end 
end
