#!/usr/bin/env ruby

class Token
  # Create a new Token
  def initialize(value = "")
    @value = value
  end

  def to_s
    return @value
  end
end

class InputHandler
  # Create new object
  def initialize(tokens = {})
    @tokens = tokens
  end

  def set(tok = "")
    if !@tokens.keys.include?(tok)
      @tokens[tok] = Token.new(tok)
    end
  end

  def get(tok = nil)
    if tok != nil
      return @tokens[tok]
    end
  end

  def get_all
    return @tokens.values.to_s
  end
end


if __FILE__ == $0
  STDOUT.sync = true
  handler = InputHandler.new
  loop do
    print "Enter Input: "
    input = gets.chomp
    handler.set(input)
    puts "You entered: " + handler.get(input).to_s
    puts handler.get_all
  end 
end
