function exp = Simplify(expression)

varNames = Exp2Varnames(expression);
expression = strrep(expression,'+','|');
expression = strrep(expression,'*','&');
expression = strrep(expression,'!','~');
eval(strjoin(['syms' varNames ';' ]));
eval(strjoin({['F =' expression ';']}));
F = simplify(F,'Steps',4800);
disp('化简后的表达式:')
disp(F)
disp(char(F))
exp = char(F);
end