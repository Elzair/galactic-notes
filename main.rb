#!/usr/bin/env ruby

require './parser.rb'
require './vm.rb'

# This class represents errors encountered by a Main object during its operations.
class MainError < RuntimeError
end

# This is the main class of the Galactic Notes program. It gets input from the user
# and manages the interactions between the lexical analyzer, the parser and the
# virtual machine. 
class Main
  def initialize(options)
    # First handle any options passed
    if options.respond_to?("has_key")
      if options.has_key("ignore_case") and options[:ignore_case] == true
        @ignore_case = true
      end
      if options.has_key("unit_test") and options[:unit_test] == true
        @unit_test = true
      end
    end

    # Next initialize Lexical Analyzer, Parser and VM
    if @ignore_case == true
     @lexer_rules = {
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
      @lexer_rules = {
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
    @lexer = Lexer.new(@lexer_rules, false) 
    @parser = Parser.new(@lexer, @ignore_case) 
    @vm = VM.new
  end

  # This method processes an array of input strings 
  # and outputs them to output_stream
  def batch_process(inputs = [], output = STDOUT, err = STDERR)
    # First ensure inputs is an array
    if !inputs.respond_to?("each")
      raise MainError, "batch_process needs an array for inputs!"
    end
    inputs.each do |input|
      process_input(input, output, err)
    end
  end

  # This method processes one statement from input
  # (which can be a stream or a string) and outputs
  # the result to output. 
  def process_input(input = STDIN, output = STDOUT, err = STDERR)
    # First make sure input, output and err are valid streams/strings
    if input.respond_to?("gets")
      is_input_stream = true
    elsif input.kind_of?(String)
      is_input_stream = false
    else
      raise MainError, "You must pass either a string or a stream for input!"
    end
    if !output.respond_to?("print") or !output.respond_to?("puts")
      raise MainError, "You must pass a valid stream for output!"
    end
    if !err.respond_to?("print") or !err.respond_to?("puts")
      raise MainError, "You must pass a valid stream for err!"
    end

    # Process user input differently if input is a stream or string
    output.print "Enter Input: "
    if is_input_stream
      inp = input.gets.chomp
    else
      inp = input
      output.puts(inp) # Display input just as if it were typed
    end
    begin
      @parser.parse_input(inp)
    rescue ParseError => e
      err.puts e.message
    end
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

  main = Main.new(options)
  # Process any input files
  main.batch_process(inputs, STDOUT, STDERR)
  # Enter main input loop
  loop do
    main.process_input(STDIN, STDOUT, STDERR)
  end 
end
