require 'stringio'
$stderr = StringIO.new
require 'parser/current'
$stderr = STDERR

def traverse(node, detector)
  detector.__send__(:"on_#{node.type}", node)
  node.children.each do |child|
    traverse(child, detector) if child.is_a?(Parser::AST::Node)
  end
end

class Detector
  def on_if(node)
    cond = node.children.first
    if cond.type == :str
      warn "Do not use a String literal in condition!!! (#{cond.loc.line}:#{cond.loc.column})"
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
traverse(ast, Detector.new)
