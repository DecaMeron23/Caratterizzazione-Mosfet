function plot_GDS(data, gds, text, folderName)
    %% Calculate gds max
    m = zeros(1, 7);
    for i=1:7
        m(i) = max(gds{i});
    end
    maximum = max(m);
    
    %% GDS - VDS
    % Create figure
    h1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot gds - Vds
    for i=1:7
        plot(data(241*(i-1)+2 : 241*i, 1), gds{i}, 'LineWidth', 1.5, 'DisplayName', ['Vgs = ', num2str(0.2*(i-1)),' V'])
    end
    
    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on', 'XLim', [0 max(data(:, 1))])
    % Y settings
    ylabel('g_{ds} [A/V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on', 'YLim', [0 maximum])
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    % Save figure
    saveas(h1, [folderName, '\figure\eps\gds_vds'], 'eps')
    saveas(h1, [folderName, '\figure\bmp\gds_vds'], 'bmp')
    saveas(h1, [folderName, '\figure\emf\gds_vds'], 'emf')
    
    %% GDS - ID
    % Create figure
    h2 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot gds - Id
    for i=1:7
        plot(data(241*(i-1)+2 : 241*i, 3), gds{i}, 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.2*(i-1)),' V'])
    end
    
    % X settings
    xlabel('Drain Current [A]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on', 'XLim', [0 max(data(:, 3))], 'XScale', 'log')
    % Y settings
    ylabel('g_{ds} [A/V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on', 'YLim', [0 maximum])
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    % Save figure
    saveas(h2, [folderName, '\figure\eps\gds_id'], 'eps')
    saveas(h2, [folderName, '\figure\bmp\gds_id'], 'bmp')
    saveas(h2, [folderName, '\figure\emf\gds_id'], 'emf')
end