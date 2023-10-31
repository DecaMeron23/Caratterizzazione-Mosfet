function plot_ID_VGS_sqrt(data, text, folderName)
    %% ID^1/2 - VGS
    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Compute sqrt(Id)
    id_sqrt = data(:, 3).^(1/2);
    
    % Plot all the series
    for i=1:7
        plot(data(301*(i-1)+1 : 301*i, 1), id_sqrt(301*(i-1)+1 : 301*i, 1), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.2*(i-1)),' V'])
    end
    
    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on')
    % Y settings
    ylabel('I_D^{1/2} [A^{1/2}]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on')
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    %% d(ID^1/2) / d(VGS) - VGS
    % Create figure
    %h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    %hold all
    
    % Compute d(Id^1/2) / d(Vgs)
    derivata = cell(1, 7);
    for i=1:7
        derivata{i} = diff(id_sqrt(301*(i-1)+1 : 301*i, 1))./ diff(data(301*(i-1)+1 : 301*i, 1));
        if length(derivata{i})>=2
            for j=length(derivata{i}):-1:2
                derivata{i}(j) = (derivata{i}(j) + derivata{i}(j-1))/2;
            end
        end
    end
    
    % Plot all the series
    for i=1:7
        plot(data(301*(i-1)+1 : 301*i-1, 1), derivata{i}, 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.2*(i-1)),' V'])
    end
    
    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on')
    % Y settings
    ylabel('d(I_D^{1/2})/d(V_{GS})', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on')
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    %% Linear regression of ID^1/2 - VGS
    Vds_index = 7;
    m = max(derivata{Vds_index});
    index = find(derivata{Vds_index} == m);
    
    interval_indeces = [index-2 index-1 index index+1 index+2];
    
    interval_VGS = zeros(1, 5);
    interval_ID = zeros(1, 5);
    for i=1:5
        interval_VGS(i) = data(301*(Vds_index-1) + interval_indeces(i), 1);
        interval_ID(i) = real(id_sqrt(301*(Vds_index-1) + interval_indeces(i)));
    end
    
    % Linear regression within the interval values
    p = polyfit(interval_VGS, interval_ID, 1);
%     f = polyval(p, data(1:301, 1));
%     assignin('base', 'f', f);
%     plot(data(1:301, 1), f)
    Vth = -p(2)/p(1);
    assignin('base', 'Vth', Vth);
    
end