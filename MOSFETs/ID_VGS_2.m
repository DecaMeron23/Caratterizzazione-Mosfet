function ID_VGS_2(file,text)
    t=readtable(file,VariableNamingRule="preserve");
    
    main=table2array(t);
    y=text(1:4);
    
    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    k=1;
    for i=1: height(main)
        if strcmp(y,'PMOS')
            main(i,1)=main(i,1)-0.9;
        end
    end
    assignin("base","main",main);
    for i=2:5: width(main)
        if i<=width(main)
            plot(main(:,1), main(:,i), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.01*(k-1)),' V']);
            k=k+1;
        end
    end
    assignin("base","k",k);
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
    
   
    
    ylabel('Drain Current [A]', 'FontSize', 12, 'FontWeight', 'bold')
    
   
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(text, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'best')
    legend('boxoff')
    
    % Save figure
    if ~exist("\eps", 'dir')
        mkdir eps;
    end
    axis square;
    saveas(h, [pwd, '\eps\idvgs-2.eps'], 'epsc')
end