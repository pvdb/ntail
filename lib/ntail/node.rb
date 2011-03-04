require 'treetop'

module Formatting
  class Node < Treetop::Runtime::SyntaxNode
    def value(log_line, color)
      raise "SubclassResponsibility" # override in node "subclasses"...
    end
    def foreground(string, color)
      color ? string.foreground(color) : string
    end
  end
end
