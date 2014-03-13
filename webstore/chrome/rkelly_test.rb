##
# Iterate over and modify a JavaScript AST.  Then print the modified
# AST as JavaScript.
require 'rkelly'

parser = RKelly::Parser.new
ast    = parser.parse(
  "something.innerHTML='askme'"
)

ast.each do |node|
  #p node.methods
#  p node.value
  p node.class
  p node.to_ecma
  #node.value  = 'hello' if node.value == 'i'
  #node.name   = 'hello' if node.respond_to?(:name) && node.name == 'i'
  if node.class==RKelly::Nodes::FunctionCallNode
    puts node.to_ecma
  end
end
#puts ast.to_ecma # => awesome javascript
