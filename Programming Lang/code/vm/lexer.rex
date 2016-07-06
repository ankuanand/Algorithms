# http://github.com/tenderlove/frex
class Parser
macro
  BLANK         \s+
  DIGIT         \d+
  PRINT         print
rule
  {BLANK}
  {DIGIT}       { [:NUMBER, text.to_i] }
  {PRINT}       { [:PRINT, text.to_sym] }
  .             { [text, text] }
inner
end
