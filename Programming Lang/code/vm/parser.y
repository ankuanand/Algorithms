# http://github.com/tenderlove/racc
class Parser
  prechigh
    left '*' '/'
    left '+' '-'
  preclow
  options no_result_var
rule
  target  : stmt
          | /* none */ { 0 }
  
  stmt    : PRINT exp   { Node.new(:PRINT, [val[1]]) }
  
  exp     : exp '+' exp { Node.new(:ADD, [val[0], val[2]]) }
          | NUMBER
end
