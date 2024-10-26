function truthTable = generateTruthTable(numVars)
    % 生成真值表的左侧
    numRows = 2^numVars;
    truthTable = zeros(numRows, numVars);
    for i = 1:numRows
        binaryString = dec2bin(i-1, numVars);
        truthTable(i, :) = binaryString - '0';
    end
end