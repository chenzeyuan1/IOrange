function plotKarnaughMap(truthTable, output)
    % 绘制卡诺图
    numVars = size(truthTable, 2);
    if numVars == 2
        % 2变量卡诺图
        kmap = reshape(output, 2, 2)';
        labels = {'00', '01'; 
                  '10', '11'};
    elseif numVars == 3
        % 3变量卡诺图
        kmap = [output(1), output(3), output(7), output(5);
                output(2), output(4), output(8), output(6)];
        labels = {'000', '001', '011', '010';
                  '100', '101', '111', '110'};
    elseif numVars == 4
        % 4变量卡诺图
        kmap = [output(1), output(3), output(7), output(5);
                output(2), output(4), output(8), output(6);
                output(9), output(11), output(15), output(13);
                output(10), output(12), output(16), output(14)];

        
        % karnaugh = num2str(kmap)

        % karnaugh = ['00 01 11 10' ; karnaugh];
        % karnaugh = [ ['AB\CD'; ' 00 ';' 01';' 11 ';' 10'] karnaugh];

        % 
        % karnaugh(1,1) = 'AB\CD';
        % karnaugh(1,[2,end]) = ['00' '01' '11' '10'];
        % karnaugh([2,end],1) = ['00'; '01'; '11'; '10'];
        
        labels = {'0000', '0001', '0011', '0010';
                  '0100', '0101', '0111', '0110';
                  '1100', '1101', '1111', '1110';
                  '1000', '1001', '1011', '1010'};
    else
        error('只支持2到4个变量的卡诺图');
    end

    % 绘制卡诺图
    disp("卡诺图")
    disp(kmap)

    % figure;
    % hold on
    % imagesc(kmap);
    % colormap(gray);
    % colorbar;
    % axis equal;
    % set(gca, 'XTick', 1:size(kmap, 2), 'YTick', 1:size(kmap, 1));
    % set(gca, 'XTickLabel', labels(1, :), 'YTickLabel', labels(:, 1));
    % title('卡诺图');
    % hold off
end