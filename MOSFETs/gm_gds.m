function gm_gds(file,text,folderName,logScale)
    tipo=file(4:6);
    tr=text(1:4);
    if strcmp (tipo,'vgs')==1 || strcmp (tipo,'vds')==1
        main=readtable(file,VariableNamingRule="preserve");
        x=table2array(main);
        k=height(main);
        assignin('base', 'main', main);
        %riduco la table a Id e Vg oppure Id e Vd---------------------------------------------
        v(:,1)=main(:,1);
        j=2;
        for i=2:5:width(main)
            l=main(:,i).Properties.VariableNames;
            t=num2str(cell2mat(l));
            v(:,j)=main(:,i);
            v=renamevars(v,"Var"+num2str(j),t);
            j=j+1;
        end
        if strcmp (tipo,'vgs')==1
            for i=1:height(v)
                
            end
            assignin('base', 'Id_Vg', v);

        end

        if strcmp (tipo,'vds')==1
            assignin('base', 'Id_Vd', v);
        end 
        %Conto numero totale di step,contanto il numero di Id presenti nella
        %table-----------------------------------------------------------------
        NomiCol=main.Properties.VariableNames;
        count=0;
        for y=1:length(NomiCol)
            j=extractBetween(NomiCol{y},1,2);
            if strcmp(j,"Id")==1
                count=count+1;
            end
        end
        gm=zeros(k-1,count);
        gds=zeros(k-1,count);
        %faccio la derivata d(Id)/d(Vg) oppure la d(Id)/d(Vds)----------------------------------------
        l=1;
        for i=2:width(v)
            if i<=width(v) && l<=count
                first=table2array(v(1:k,i));
                second=table2array(v(1:k,1));
                if strcmp (tipo,'vgs')==1
                    gm(:,l)=diff(first)./ diff(second);
                end
                if strcmp (tipo,'vds')==1
                    gds(:,l)=diff(first)./ diff(second);
                end
                if strcmp(tipo,'vgs')==1
                    if height(gm(:,l))>=2
                        for j=height(gm(:,l)):-1:2
                            gm(j,l)=(gm(j,l)+gm(j-1,l))/2;
                        end
                    end
                end
                 if strcmp(tipo,'vds')==1
                    if height(gds(:,l))>=2
                        for j=height(gds(:,l)):-1:2
                            gds(j,l)=(gds(j,l)+gds(j-1,l))/2;
                        end
                    end
                end
                l=l+1;
            end    
        end
        if strcmp (tipo,'vgs')==1
            finale=array2table(gm);
            f=1;
            v="gm,Vd=";
            o=0.15;
            a=["gm"+num2str(f),"gm"+num2str(f+1),"gm"+num2str(f+2),"gm"+num2str(f+3),"gm"+num2str(f+4),"gm"+num2str(f+5),"gm"+num2str(f+6)];
            b=[v+num2str(o*0)+"V",v+num2str(o*1)+"V",v+num2str(o*2)+"V",v+num2str(o*3)+"V",v+num2str(o*4)+"V",v+num2str(o*5)+"V",v+num2str(o*6)+"V"];
            finale=renamevars(finale,a,b);
            assignin('base', 'gm', finale);
        end

        if strcmp (tipo,'vds')==1
            finale=array2table(gds);
            f=1;
            v="gds,Vg=";
            o=0.15;
            a=["gds"+num2str(f),"gds"+num2str(f+1),"gds"+num2str(f+2),"gds"+num2str(f+3),"gds"+num2str(f+4),"gds"+num2str(f+5),"gds"+num2str(f+6)];
            b=[v+num2str(o*0)+"V",v+num2str(o*1)+"V",v+num2str(o*2)+"V",v+num2str(o*3)+"V",v+num2str(o*4)+"V",v+num2str(o*5)+"V",v+num2str(o*6)+"V"];
            finale=renamevars(finale,a,b);
            assignin('base', 'gds', finale);
        end
    
        %calcolo gm_max o gds_max da plottare--------------------------------------------
        m=zeros(1,count);
        if strcmp (tipo,'vgs')==1
            m=max(gm);
        end
        if strcmp (tipo,'vds')==1
            m=max(gds);
        end
        maximum=max(m);
        assignin('base', 'max', maximum);
        %----------------------------------------------------------------------
    
         %% GM - VGS
        % Create figure
        h1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        hold all

        

        % Plot Gm - Vgs
        if strcmp (tipo,'vgs')==1 && logScale==false 
            for i=1:count
             
                plot(x(1:k-1, 1), gm(:,i), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.15*(i-1)),' V'])
            end
        end
    
        if strcmp (tipo,'vgs')==1 && logScale==true
            %con i=4 prendo lo step intermedio
            i=4;
            plot(x(1:k-1, 1), abs(gm(:,i)), 'LineWidth', 1.5, 'DisplayName', ['Vds = ', num2str(0.15*(i-1)),' V'])
            
        end

        % Plot Gds - Vds
        if strcmp (tipo,'vds')==1 && logScale==false
            if tr=="NMOS"
                 x(1,1)=x(2,1);
                 x(3,1)=x(4,1);
            end

           
            for i=1:count
                if tr=="NMOS"
                    gds(1,i)=gds(2,i);
                gds(3,i)=gds(4,i);
                end

                
                plot(x(1:k-1, 1), gds(1:end,i), 'LineWidth', 1.5, 'DisplayName', ['Vgs = ', num2str(0.15*(i-1)),' V'])
            end
        end
    
        if strcmp (tipo,'vds')==1 && logScale==true
            %con i=4 prendo lo step intermedio
            i=4;
            plot(x(1:k-1, 1), abs(gds(:,i)), 'LineWidth', 1.5, 'DisplayName', ['Vgs = ', num2str(0.15*(i-1)),' V'])
            
        end
    
        % X settings
        if strcmp (tipo,'vgs')==1
            xlabel('Gate-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
        end
        if strcmp (tipo,'vds')==1
            xlabel('Drain-to-Source Voltage [V]', 'FontSize', 12, 'FontWeight', 'bold')
        end
        if logScale==false
            set(gca, 'XMinorTick', 'on', 'XLim', [0 max(x(:, 1))])
        end

        if logScale==true
            set(gca, 'XMinorTick', 'on', 'XLim', [-0.3 max(x(:, 1))])
        end

        % Y settings
        if strcmp (tipo,'vgs')==1
            ylabel('g_m [A/V]', 'FontSize', 12, 'FontWeight', 'bold')
        end
        if strcmp (tipo,'vds')==1
            ylabel('g_{ds} [A/V]', 'FontSize', 12, 'FontWeight', 'bold')
        end
        if logScale==false
            set(gca, 'YMinorTick', 'on', 'YLim', [0 maximum])
        end
        
        if logScale==true
            set(gca,'YScale','log')
        end
        
        
        % Ticks settings
        set(gca, 'FontSize', 12, 'FontWeight', 'bold')
        
        % Figure properties
        title(text, 'Interpreter', 'none')
        set(gca, 'Position', [0.06, 0.07, 0.92, 0.87])
        if strcmp (tipo,'vgs')==1
            legend('Location', 'Northwest')
        end
        if strcmp (tipo,'vds')==1
            legend('Location', 'northeast')
        end
        legend('boxoff')
        if ~exist("\eps", 'dir')
            mkdir eps;
        end
        axis square;
        % Save figure
        if strcmp (tipo,'vgs')==1 && logScale==false
            saveas(h1, [pwd, '\eps\gm_vgs.eps'], 'epsc');
        end
        if strcmp (tipo,'vgs')==1 && logScale==true
            saveas(h1, [pwd, '\eps\gm_vgs_log.eps'], 'epsc');
        end
        if strcmp (tipo,'vds')==1 && logScale==false
            saveas(h1, [pwd, '\eps\gds_vds.eps'], 'epsc');
        end
        if strcmp (tipo,'vds')==1 && logScale==true
            saveas(h1, [pwd, '\eps\gds_vds_log.eps'], 'epsc');
        end
        %cd(folderName);
        if strcmp (tipo,'vgs')==1
            writetable(finale,'gm-vgs.txt','Delimiter','\t','WriteRowNames',true);
        end
        if strcmp (tipo,'vds')==1
            writetable(finale,'gds-vds.txt','Delimiter','\t','WriteRowNames',true);
        end
        
    end
end