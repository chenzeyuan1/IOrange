function logicExpression = mintermsToLogicExpression(minterms, numVars)
    % 生成卡诺图
    kmap = generateKMap(minterms, numVars);
    
    % 简化卡诺图
    logicExpression = simplifyKMap(kmap, numVars);
end

function kmap = generateKMap(minterms, numVars)

    kmapSize = 2^numVars;
    kmap = zeros(1, kmapSize);
   
    for i = 1:length(minterms)
        kmap(minterms(i) + 1) = 1;
    end
end
function expression = simplifyKMap(kmap, numVars)
    % 简化卡诺图
    expression = '';
    character = ['A','B','C','D'];
    for i = 1:length(kmap)
        if kmap(i) == 1
            term = '';
            binaryIndex = dec2bin(i-1, numVars);
            for j = 1:numVars
                if binaryIndex(j) == '1'
                    if j == 1
                        term = [term,character(j)];
                    else
                        term = [term, ' & ',character(j)];
                    end
                else
                    if j == 1
                        term = [term,'~',character(j)];
                    else
                        term = [term, '& ~',character(j)];
                    end
                    
                end
            end
            if isempty(expression)
                expression = term;
            else
                expression = [expression, ' +', term];
            end
        end
    end
end
