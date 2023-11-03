function plot_ID_VDS(data,text ,folderName)
    k=text(1:4);
    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    % Plot all the series
    % i= numero di valori che vg assume
    % numero di vg che rimangono fissi
    t=data(:,2);
    [~,~,ix] = unique(t);
    C = accumarray(ix,1).';
    if strcmp(k,'NMOS')==1
        for i=1:length(C)
        plot(data(C(1,i)*(i-1)+1 : C(1,i)*i, 1), data(C(1,i)*(i-1)+1 : C(1,i)*i, 3), 'LineWidth', 1.5, 'DisplayName', ['Vgs = ', num2str(0.15*(i-1)),' V'])
        end
    end
    if strcmp(k,'PMOS')
        for i=1:length(C)
            if i<length(C)
                plot(data(C(1,i)*(i-1)+1 : C(1,i)*i, 1)-0.9, data(C(1,i)*(i-1)+1 : C(1,i)*i, 3), 'LineWidth', 1.5, 'DisplayName', ['Vgs = ', num2str((0.15*(i-1))-0.9),' V'])
            end
            if i==length(C)
                plot(data(C(1,i)*(i-1)+1 : C(1,i)*i, 1)-0.9, data(C(1,i)*(i-1)+1 : C(1,i)*i, 3), 'LineWidth', 1.5, 'DisplayName', ['Vgs = ', num2str(0),' V'])
            end
        end
    end
    
    if strcmp(k,'NMOS')==1
        xlim([0 0.9]);
    end 
    
   
    % X settings
    
        xlabel('Drain-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    
    
     
    set(gca, 'XMinorTick', 'on')
    % Y settings
    ylabel('Drain Current [A]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on')
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    if k=="NMOS"
        legend('Location', 'northwest')
    end
    if k=="PMOS"
        legend('Location', 'best')
    end
    
    legend('boxoff')
    axis square; 
    % Save figure
    saveas(gcf, [folderName, '\eps\id_vds.eps'], 'epsc') % #modifica inserito gcf, al posto di h, sennò dava errore e non salvava il file
end