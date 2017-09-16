require 'stringio'
$stderr = StringIO.new
require 'parser/current'
$stderr = STDERR

def traverse(node, visitor)
  visitor.__send__(:"on_#{node.type}", node)
  node.children.each do |child|
    traverse(child, visitor) if child.is_a?(Parser::AST::Node)
  end
end

class Visitor
  def on_if(node)
    cond = node.children.first
    if cond.type == :int
      warn "Do not use an int literal in condition!!! (#{cond.loc.line}:#{cond.loc.column})"
    end
  end

  def method_missing(name, *args)
    if name.to_s.start_with?('on_')
      # nothing
    else
      super
    end
  end
end

ast = Parser::CurrentRuby.parse(ARGF.read)
traverse(ast, Visitor.new)
