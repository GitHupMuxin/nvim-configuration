syntax match netrwCppHeader /\c\%(\S\+ \)*\S\+\.\%(h\|hh\|hpp\|hxx\)\ze\%(\s\{2,}\|$\)/ contains=@NoSpell
syntax match netrwCppSource /\c\%(\S\+ \)*\S\+\.\%(cpp\|cc\|cxx\)\ze\%(\s\{2,}\|$\)/ contains=@NoSpell
syntax cluster NetrwTreeGroup add=netrwCppHeader,netrwCppSource
highlight default link netrwCppHeader Type
highlight default link netrwCppSource Function
