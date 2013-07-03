#!/usr/bin/env ruby

require './parser.rb'
require './vm.rb'

class Main
  def initialize(options)
    # First handle any options passed
    if options.responds_to?("has_key")
      if options.has_key("ignore_case") and options[:ignore_case] == true
        @ignore_case = true
      end
      if options.has_key("unit_test") and options[:unit_test] == true
        @unit_test = true
      end
    end

    # Next initialize Lexical Analyzer, Parser and VM
    if @ignore_case == true
     @rules = {
        "HOW" => "HOW",
        "MANY" => "MANY",
        "MUCH" => "MUCH",
        "IS" => "IS",
        "QUIT" => "QUIT",
        "CREDITS" => "CREDITS",
        "[[:alpha:]]+" => "VARIABLE",
        "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
        "\\?" => "QUESTION",
        "\\s" => "WS",
        "\n" => "EOL"
      }
    else
      @rules = {
        "How" => "HOW",
        "many" => "MANY",
        "much" => "MUCH",
        "is" => "IS",
        "quit" => "QUIT",
        "Credits" => "CREDITS",
        "[[:alpha:]]+" => "VARIABLE",
        "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
        "\\?" => "QUESTION",
        "\\s" => "WS",
        "\n" => "EOL"
      }
    end
    @lexer = Lexer.new(@rules, false) 
    @parser = Parser.new(@lexer, @ignore_case) 
    @vm = VM.new
  end
end

if __FILE__ == $0
  # First handle command line arguments
  options = {} # Stores values of command line flags
  inputs = [] # Stores statements read from input files
  ARGV.each do |a|
    #puts "Argument: #{a}"
    case a
    when "-i"
      options[:ignore_case] = true
    when "-u"
      options[:unit_test] = true
    else # The program considers anything else a filename
      begin
        file = File.open(a)
        while !file.eof
          inputs.push(file.readline.chomp)
        end
      rescue
        STDERR.puts "Cannot open file: #{a}!"
      ensure
        file.close()
      end
    end
  end
  # Flush STDIN to prevent input from spilling over into main loop
  STDIN.flush
  #vm = VM.new
  #parser = GalacticParser.new(vm, ignore_case)
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
