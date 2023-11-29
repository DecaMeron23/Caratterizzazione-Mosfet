function plot_ID_VGS(data, text, folderName)
    k=text(1:4);
    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot all the series
    
    t=data(:,2);
    [~,~,ix] = unique(t);
    C = accumarray(ix,1).';
    for i=1:length(C)
        if strcmp(k,'PMOS') 
            if i<length(C)
            plot(data(C(1,i)*(i-1)+1 : C(1,i)*i, 1)-0.9, data(C(1,i)*(i-1)+1 : C(1,i)*i, 3), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.15*(i-1)-0.9),' V'])
            end
            if i==length(C)
            plot(data(C(1,i)*(i-1)+1 : C(1,i)*i, 1)-0.9, data(C(1,i)*(i-1)+1 : C(1,i)*i, 3), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0),' V'])
            end
        end
        if strcmp(k,'NMOS')
            if i<=length(C)
            plot(data(C(1,i)*(i-1)+1 : C(1,i)*i, 1), data(C(1,i)*(i-1)+1 : C(1,i)*i, 3), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.15*(i-1)),' V'])
            end
        end
        
    end
    

    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on')
    if strcmp(k,'NMOS')
            xlim([-0.3 0.9])
    end
    if strcmp(k,'PMOS')
            xlim([-0.9 0.3])
    end
    % Y settings
    ylabel('Drain Current [A]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on')
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'best')
    legend('boxoff')
    
    % Save figure
    axis square;
        saveas(h, [folderName, '\eps\id_vgs.eps'], 'epsc')
   
    
end