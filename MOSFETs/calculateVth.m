function calculateVth(data, id_sqrt, titleText, folderName)
    %% Compute d(Id^1/2) / d(Vgs)
    derivata = cell(1, 7);
    for i=1:7
        derivata{i} = diff(id_sqrt(301*(i-1)+1 : 301*i, 1))./ diff(data(301*(i-1)+1 : 301*i, 1));
        if length(derivata{i})>=2
            for j=length(derivata{i}):-1:2
                derivata{i}(j) = (derivata{i}(j) + derivata{i}(j-1))/2;
            end
        end
    end
    
    %% Linear regression of ID^1/2 - VGS
    Vds_index = 7;
    %m = max(derivata{Vds_index});
    %index = find(derivata{Vds_index} == m);
    n = 0.58;
    index = (n - (-0.3))/0.005 + 1;
    
    interval_indeces = [index-2 index-1 index index+1 index+2];
    
    interval_VGS = zeros(1, 5);
    interval_ID = zeros(1, 5);
    for i=1:5
        interval_VGS(i) = data(301*(Vds_index-1) + interval_indeces(i), 1);
        interval_ID(i) = real(id_sqrt(301*(Vds_index-1) + interval_indeces(i)));
    end
    
    % Linear regression within the interval values
    p = polyfit(interval_VGS, interval_ID, 1);
    Vth = -p(2)/p(1);
    assignin('base', 'Vth', Vth);
    
    %% Plot ID^1/2 - VGS (VDS = 1.2V) and interpolation line
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    plot(data(301*(Vds_index-1)+1 : 301*Vds_index, 1), id_sqrt(301*(Vds_index-1)+1 : 301*Vds_index, 1), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.2*(Vds_index-1)),' V'])
    
    f = polyval(p, data(301*(Vds_index-1)+1 : 301*Vds_index, 1));
    plot(data(301*(Vds_index-1)+1:301*(Vds_index), 1), f, 'r', 'LineWidth', 1.5, 'DisplayName', 'Interpolation')
    
    % X settings
    xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on')
    % Y settings
    ylabel('I_D^{1/2} [A^{1/2}]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'YMinorTick', 'on', 'YLim', [0 f(end)])
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    title(titleText, 'Interpreter', 'none')
    set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location', 'Northwest')
    legend('boxoff')
    
    % Write Vth on plot - COPY AND PASTE IN THE COMMAND WINDOW (AND EDIT Y POSITION)
    text(-0.318, 0.52, ['V_{TH} = ' num2str(Vth) ' V'], 'FontSize', 12, 'FontWeight', 'bold')
    
    % Save figure
    saveas(h, [folderName, '\figure\eps\Vth'], 'eps')
    saveas(h, [folderName, '\figure\bmp\Vth'], 'bmp')
    saveas(h, [folderName, '\figure\emf\Vth'], 'emf')
end

