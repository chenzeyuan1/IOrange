function Compile(filePath)
    %这是一个编译器，可以编译我设计的语言
    fileID = fopen(filePath, 'r');
    
    % 检查文件是否成功打开
    if fileID == -1
        error('无法打开文件,编译失败。');
    end
    
    % 初始化一个空的 cell 数组来存储分割后的内容
    fileContent = {};
    
    % 逐行读取文件内容
    while ~feof(fileID)
        line = fgetl(fileID);
        % 以 ; 为分界符分割每一行的内容
        splitLine = strsplit(line, ';');
        % 将分割后的内容添加到 fileContent 中
        fileContent = [fileContent, splitLine];
    end
    
    for i = 1:length(fileContent)
        if contains(fileContent{i}, 'let')
            VarNames = parseLine(fileContent{i})
        end
        if contains(fileContent{i}, '=')
            Expression = parseExpression(fileContent{i})
        end
        if contains(fileContent{i}, 'Simulate')
            SimulateLogicCircuit(Expression, VarNames);
        end
    end
    % 关闭文件
    fclose(fileID);
    
end
function result = parseLine(line)
    %解析let语句
    line = [line, ' '];
    % 去除 'let ' 前缀和 ';' 后缀
    line = strrep(line, 'let ', '');
    line = strrep(line, ';', '');
    result = strsplit(line, ' ');
    result = result(~cellfun('isempty', result));
    result =strjoin(['{' result '}']);
end
function result = parseExpression(line)
     % 定义正则表达式模式
     line
     pattern = '=\s*(.*?);';
    
     % 使用正则表达式匹配等号前后的内容
     matches = regexp(line, pattern, 'tokens');
     
     % 如果有匹配结果
     if ~isempty(matches)
         % 提取匹配的内容
        
         rightSide = strtrim(matches{1}{1}); % 等号后的内容
         result = rightSide;
     else
         result = {};
     end
end