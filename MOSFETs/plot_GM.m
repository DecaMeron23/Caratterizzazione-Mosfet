function plot_GM(data, gm, text, folderName)
    %% Calculate gm max to plot
    m = zeros(1, 7);
    for i=1:7
        m(i) = max(gm{i});
    end
    maximum = max(m);
    
    %% GM - VGS
    % Create figure
    h1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot gm - Vgs
    for i=1:7
        plot(data(301*(i-1)+1 : 301*i-1, 1), gm{i}, 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.2*(i-1)),' V'])
    end
    
    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on', 'XLim', [0 max(data(:, 1))])
    % Y settings
    ylabel('g_m [A/V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on', 'YLim', [0 maximum])
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    % Save figure
    saveas(h1, [folderName, '\figure\eps\gm_vgs'], 'eps')
    saveas(h1, [folderName, '\figure\bmp\gm_vgs'], 'bmp')
    saveas(h1, [folderName, '\figure\emf\gm_vgs'], 'emf')
    
    %% GM - ID
    % Create figure
    h2 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot gm - Id
    for i=1:7
        plot(data(301*(i-1)+1 : 301*i-1, 3), gm{i}, 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.2*(i-1)),' V'])
    end
    
    % X settings
    xlabel('Drain Current [A]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on', 'XLim', [0 max(data(:, 3))])
    % Y settings
    ylabel('g_m [A/V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on', 'YLim', [0 maximum])
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    % Save figure
    saveas(h2, [folderName, '\figure\eps\gm_id'], 'eps')
    saveas(h2, [folderName, '\figure\bmp\gm_id'], 'bmp')
    saveas(h2, [folderName, '\figure\emf\gm_id'], 'emf')
end