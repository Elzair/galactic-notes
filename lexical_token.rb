
# This class represents a lexical token.
class Token
  attr_accessor :type   # the type of token
  attr_accessor :value  # the value of token
  attr_accessor :pos    # the position of the token in the input stream

  # This method creates a new Token object.
  # - type: a String containing the type of token
  # - value: a String containing the value of a token
  # - pos: a FixNum representing a token's starting position in an input string
  def initialize(type = "", value = "", pos = -1)
    @type = type
    @value = value
    @pos = pos
  end

  # This method overrides the toString method to return a string containing
  # all the info in the token (NOTE: FOR DEBUGGING PURPOSES ONLY)
  def to_s
    return "[ #{@type} #{@value.to_s} #{@pos.to_s} ]" 
  end
end

