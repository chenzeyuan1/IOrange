function model = SimulateLogicCircuit(expression)
    % 解析逻辑符号表达式并在 Simulink 中生成逻辑电路图
    % 输入：逻辑表达式（字符串形式）和变量名数组
    
    varNames = Exp2Varnames(expression);
    % 解析逻辑符号表达式
    [gates, connections, final_output] = parse_expression(expression);
    
    model = create_simulink_model(gates, connections, final_output, varNames);
    
    % set_param(model, 'StopTime', '10');  % 仿真时间为10秒
    % 
    % simOut = sim(model);
    % 
    % output = simOut.get('yout');
    % 
    % disp('仿真结果:');
    % for i = 1:numel(output)
    %     signal = output{i};
    %     disp(['Signal Name: ', signal.Name]);
    %     disp(['Block Path: ', signal.BlockPath.getBlock(1)]);
    %     disp('Signal Data:');
    %     disp(signal.Values.Data);
    % end
end

function [gates, connections, final_output] = parse_expression(expression)
    % 解析逻辑符号表达式
    % 输出：逻辑门和连接关系
    
    gates = {};
    connections = {};
    
    % 解析表达式
    expr = strrep(expression, ' ', '');  
    expr = strrep(expr, '&', ' AND ');
    expr = strrep(expr, '*', ' AND ');
    expr = strrep(expr, '|', ' OR ');
    expr = strrep(expr, '+', ' OR ');
    expr = strrep(expr, '~', ' NOT ');
    expr = strrep(expr, '!', ' NOT ');
    
    % 分割表达式
    tokens = regexp(expr, '(\(|\)|AND|OR|NOT|[a-zA-Z0-9_]+)', 'match');
    % varNames = tokens;
    % removechars = {'NOT','AND','OR'};
    % for i = 1:length(removechars)
    %     removechar = removechars{i};
    %     varNames = cellfun(@(str)strrep(str,removechar,''),varNames,'UniformOutput',false);
    % end
    opStack = {};
    outQueue = {};
    
    % 运算符优先级
    precedence = containers.Map({'NOT', 'AND', 'OR'}, {3, 2, 1});
    
    % 生成逻辑门和连接关系
    for i = 1:length(tokens)
        token = tokens{i};
        if any(strcmp(token, {'AND', 'OR', 'NOT'}))
            while ~isempty(opStack) && isKey(precedence, opStack{end}) && precedence(opStack{end}) >= precedence(token)
                outQueue{end+1} = opStack{end};
                opStack(end) = [];
            end
            opStack{end+1} = token;
        elseif strcmp(token, '(')
            opStack{end+1} = token;
        elseif strcmp(token, ')')
            while ~strcmp(opStack{end}, '(')
                outQueue{end+1} = opStack{end};
                opStack(end) = [];
            end
            opStack(end) = [];  % 弹出 '('
        else
            outQueue{end+1} = token;
        end
    end
    
    while ~isempty(opStack)
        outQueue{end+1} = opStack{end};
        opStack(end) = [];
    end
    
    % 处理输出队列生成逻辑门和连接关系
    stack = {};
    for i = 1:length(outQueue)
        token = outQueue{i};
        if any(strcmp(token, {'AND', 'OR', 'NOT'}))
            if strcmp(token, 'NOT')
                operand = stack{end};
                stack(end) = [];
                gates{end+1} = token;
                connections{end+1} = [operand, ' -> ', token, num2str(length(gates))];
                stack{end+1} = [token, num2str(length(gates))];
            else
                operand2 = stack{end};
                stack(end) = [];
                operand1 = stack{end};
                stack(end) = [];
                gates{end+1} = token;
                connections{end+1} = [operand1, ' -> ', token, num2str(length(gates))];
                connections{end+1} = [operand2, ' -> ', token, num2str(length(gates))];
                stack{end+1} = [token, num2str(length(gates))];
            end
        else
            stack{end+1} = token;
        end
    end
    
    % 最终输出信号
    final_output = stack{end};
    
end

function model = create_simulink_model(gates, connections, final_output, varNames)
    % 在 Simulink 中生成逻辑电路图
    % 输入：逻辑门和连接关系，变量名数组
    
    model = 'logic_circuit';
    open_system(new_system(model));
    
    % 添加逻辑门和连接关系
    for i = 1:length(gates)
        gate = gates{i};
        if strcmp(gate, 'AND')
            add_block('simulink/Logic and Bit Operations/Logical Operator', [model, '/AND', num2str(i)], 'Operator', 'AND');
        elseif strcmp(gate, 'OR')
            add_block('simulink/Logic and Bit Operations/Logical Operator', [model, '/OR', num2str(i)], 'Operator', 'OR');
        elseif strcmp(gate, 'NOT')
            add_block('simulink/Logic and Bit Operations/Logical Operator', [model, '/NOT', num2str(i)], 'Operator', 'NOT');
        end
    end
    
    % 添加输入端口
    for i = 1:length(varNames)
        add_block('simulink/Sources/In1', [model, '/', varNames{i}]);
        set_param([model, '/', varNames{i}], 'OutDataTypeStr', 'boolean');
        % set_param([model, '/', varNames{i}], 'Period', '10', 'PulseWidth', '5', 'Amplitude', '1');
    end
    
    % 添加输出端口
    add_block('simulink/Sinks/Out1', [model, '/Output']);
    set_param([model, '/Output'], 'OutDataTypeStr', 'boolean');

    % 连接逻辑门和端口
    for i = 1:length(connections)
        conn = connections{i};
        tokens = strsplit(conn, ' -> ');
        src = tokens{1};
        dst = tokens{2};
        
        % 检查目标端口是否已有信号线连接
        lines = get_param([model, '/', dst], 'LineHandles');
        if lines.Inport(1) == -1
            add_line(model, [src, '/1'], [dst, '/1']);
        else
            % 找到下一个可用的输入端口
            for j = 2:length(lines.Inport)
                if lines.Inport(j) == -1
                    add_line(model, [src, '/1'], [dst, '/', num2str(j)]);
                    break;
                end
            end
        end
    end
    
    % 连接最终输出信号到输出端口
    add_line(model, [final_output, '/1'], 'Output/1');
    
    Simulink.BlockDiagram.arrangeSystem(model);
    
    save_system(model);
end