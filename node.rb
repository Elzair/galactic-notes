
# This class represents a node in the Abstract Syntax Tree
class Node
  attr_accessor :name      # Name of node
  attr_accessor :value     # Value of node
  attr_accessor :children  # Array of child Nodes
  attr_accessor :is_root   # Whether or not this node is a root node
  attr_accessor :is_leaf   # Whether or not this node is a leaf node

  # This method creates a new node
  # - name: a String representing the name of this node
  # - value: an Object representing the value of this node
  #          (should be nil unless node is a leaf node)
  # - children: an Array of child Nodes of this node
  # - is_root: whether or not this node is a root node
  # - is_leaf: whether or not tis node is a leaf node
  def initialize(name = "", value = nil, children = [], is_root = false, is_leaf = false)
    @name = name
    @value = value
    @children = children
    @is_root = is_root
    @is_leaf = is_leaf
  end

  # This method returns a String representation of this node.
  # NOTE: For Debugging purposes only!
  # - show_children: whether or not to include child nodes
  # return: a String of the attributes of this node (and possibly child nodes)
  def to_s(show_children = true)
    # Since @value can be nil & nil does not have a to_s method
    # we need to specify nil some other way 
    out = "[ " + @name + " "
    if @value == nil
      out = out + "nil "
    else
      out = out + @value.to_s + " "
    end
    # If show_children is true, show child nodes in brackets
    if show_children == true
      if @children == []
        out = out + "[] "
      else
        children.each do |child|
          out = out + child.to_s
        end
      end
    end
    out = out + @is_root.to_s + " " + @is_leaf.to_s + " ] "
    return out
  end
end

