function output = evaluateExpression(truthTable, expression, varNames)
    numRows = size(truthTable, 1);
    output = zeros(numRows, 1);
    for i = 1:numRows
        for j = 1:length(varNames)
            eval([varNames{j} ' = truthTable(i, j);']);
        end
        output(i) = eval(expression);
    end
end