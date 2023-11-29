function plot_ID_VGS_log(data, text, folderName)
    y=text(1:4);
    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot all the series
    t=data(:,2);
    [~,~,ix] = unique(t);
    C = accumarray(ix,1).';
    for i=1: height(data)
        if strcmp(y,'PMOS')
            data(i,1)=data(i,1)-0.9;
        end
    end
    %Vado a verificare per 0.45 Vds,che sarebbe il quarto passo.
    i=4;
    plot(data(C(1)*(i-1)+1 : C(1)*i, 1), abs(data(C(1)*(i-1)+1 : C(1)*i, 3)), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.15*(i-1)),' V'])
    
    if strcmp(y,'PMOS')
      xlim([-0.9 0.3])
    end
    if strcmp(y,'NMOS')
      xlim([-0.3 0.9])
    end
    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on')
    % Y settings
    k=text(1:4);
    if(strcmp(k,'PMOS')==1)
    ylabel('|Drain Current| [A]', 'FontSize', 12, 'FontWeight', 'bold')
    end
    if(strcmp(k,'NMOS')==1)
    ylabel('Drain Current [A]', 'FontSize', 12, 'FontWeight', 'bold')
    end
    set(gca, 'YMinorTick', 'on', 'YScale', 'log')
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    if y=="NMOS"
        legend('Location', 'northwest')
    end
    if y=="PMOS"
        legend('Location', 'best')
    end
    
    legend('boxoff')
    axis square;
    % Save figure
    saveas(h, [folderName, '\eps\id_vgs_log.eps'], 'epsc')
end