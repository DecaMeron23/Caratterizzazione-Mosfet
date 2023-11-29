function gm_id (file1,file2,titleText,folderName)
    tipo=titleText(1:4);
    W=str2double(extractBetween(titleText,'W','L'));
    L=str2double(extractAfter(titleText,'L'));
    if tipo=="NMOS"
        L=str2double(extractAfter(titleText,'L'))/(10^3);
    end
    
    gm=readtable(file1,VariableNamingRule="preserve");
    Id0=readtable(file2,VariableNamingRule="preserve");
    
    v=table();
    j=1;
    for i=2:5:width(Id0)
         l=Id0(:,i).Properties.VariableNames;
         t=num2str(cell2mat(l));
         v(:,j)=Id0(:,i);
         v=renamevars(v,"Var"+num2str(j),t);
         j=j+1;
    end
    
    %taglio l'ultimo valore che non mi serve
    Id=v(1:height(v)-1,:);
    
    ID=table2array(Id);
    
    GM=table2array(gm);
    if tipo=="PMOS"
        ID=abs(ID);
        GM=abs(GM);
    end
    
    value=L/W;
    x=zeros(length(ID),width(ID));
    for j=1:width(ID)
        for i=1:length(ID)
            x(i,j)=ID(i,j)*value;
        end
    end

    y=zeros(length(GM),width(GM));
    for j=1:width(ID)
        for i=1:length(ID)
            y(i,j)=GM(i,j)/ID(i,j);
        end
    end
    
    
    assignin("base","x",x);
    assignin("base","y",y);

    % Create figure
    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    hold all
    
    %% Plot Id*(L/W) - gm/Id
    if height(x)==height(y) && width(x)==width(y) 
       i=7;
       plot(x(1:height(x),i),y(1:height(y),i), 'LineWidth', 1.5, 'DisplayName', ['28 nm - ',tipo,' ',num2str(W),'/',num2str(L),' Vd=', num2str(0.15*(i-1)),' V'])

    end

    % X settings
    xlabel('I_{d} W/L [A]', 'FontSize', 12, 'FontWeight', 'bold')
    set(gca, 'XMinorTick', 'on','XScale','log')
    set(gca, 'XMinorTick', 'on','YScale','log')
    xlim ([(10^-9) (10^-5)]);
    
    
    % Y settings
    ylabel('g_{m}/I_{d} [1/V]', 'FontSize', 12, 'FontWeight', 'bold')
    
    
    ylim([1 100])
    % Ticks settings
    set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    
    % Figure properties
    %axis square;
    title(titleText, 'Interpreter', 'none')
    %set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
    legend('Location','northeast')
    legend('boxoff')
    axis square;
    % Save figure
    saveas(h, [pwd, '\eps\gm_Id.eps'], 'epsc')
   
end