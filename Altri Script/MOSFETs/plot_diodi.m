function plot_diodi(data, text, folderName)
    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
   % hold all
    
    % Plot all the series
   % for i=1:7
        plot(data(1 : 121, 1), data(1 : 121, 2), 'LineWidth', 1.5, 'DisplayName', ['pn 24'])
    %end
    
    % X settings
    xlabel('Vp [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on')
    % Y settings
    ylabel('Ip [A]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on')
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    % Save figure
    saveas(h, [folderName, '\figure\eps\pn'], 'eps')
    saveas(h, [folderName, '\figure\bmp\pn'], 'bmp')
    saveas(h, [folderName, '\figure\emf\pn'], 'emf')
end