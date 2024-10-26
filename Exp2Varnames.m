function varNames = Exp2Varnames(expression)
 % 从表达式解析出变量名
    expr = strrep(expression, ' ', '');  
    expr = strrep(expr, '&', ' AND ');
    expr = strrep(expr, '*', ' AND ');
    expr = strrep(expr, '|', ' OR ');
    expr = strrep(expr, '+', ' OR ');
    expr = strrep(expr, '~', ' NOT ');
    expr = strrep(expr, '!', ' NOT ');
    
    % 分割表达式
    tokens = regexp(expr, '(\(|\)|AND|OR|NOT|[a-zA-Z0-9_]+)', 'match');
    varNames = tokens;
    removechars = {'NOT','AND','OR','(',')','（','）'};
    for i = 1:length(removechars)
        removechar = removechars{i};
        varNames = cellfun(@(str)strrep(str,removechar,''),varNames,'UniformOutput',false);
    end
    varNames = varNames(~cellfun('isempty', varNames));
    varNames = unique(varNames);
    varNames = sort(varNames);
end