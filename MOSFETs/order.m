classdef order
    methods(Static)
        function k= ordered(file,begin,step,bound)
            originale=readtable(file);
            assignin('base', 'originale', originale);
            k=originale(:,2);
            [~,~,ix] = unique(k);
            values = accumarray(ix,1).';
            count=0;
            for i=1:length(values)-1
                if(values(i)==values(i+1) && i<length(values))
                    count=count+1;
                end
            end
            if(count==(length(values)-1))
                s=values(1);
                numcolonne=size(originale,2);
                j=(numcolonne-2)*(size(values,2));
                %devo considerare colonna iniziale
                q=zeros(s,j+1);
                ordinato=array2table(q);
                %assignin=salvo nel workspace le variabili
                assignin('base', 'ordinato', ordinato);
                [~,name,~] = fileparts(file);
                if(strcmp(name,'id-vds')==1 && strcmp(name,'id-vgs')==0)
                    ordinato=renamevars(ordinato,"q1","Vd");
                    v='Vg';
                end
                if(strcmp(name,'id-vgs')==1 && strcmp(name,'id-vds')==0)
                    ordinato=renamevars(ordinato,"q1","Vg");
                    v='Vd';
                end

                if(strcmp(name,'id-vgs-2')==1)
                    ordinato=renamevars(ordinato,"q1","Vg");
                    v='Vd';
                end
                j=2;
                k=size(originale,2)-2;
                %assegno i nomi alle colonne
                while(j<=size(ordinato,2)-3 && begin<=bound)
                    a=["q"+num2str(j),"q"+num2str(j+1),"q"+num2str(j+2),"q"+num2str(j+3),"q"+num2str(j+4)];
                    b=["Id,"+v+"="+num2str(begin)+"V","Ig,"+v+"="+num2str(begin)+"V","Is,"+v+"="+num2str(begin)+"V","Iavdd,"+v+"="+num2str(begin)+"V","Ignd,"+v+"="+num2str(begin)+"V"];
                    ordinato=renamevars(ordinato,a,b);
                    begin=begin+step;
                    j=j+k;
                end
                %assegno i valori
                %indice deve partire da 1,0 invalid
                ordinato(1:s,1)=originale(1:s,1);
                h=2;
                for i=1:s:size(originale,1)
                    ordinato(1:s,h:h+4)=originale(i:i+s-1,size(originale,2)-4:size(originale,2));
                    h=h+size(originale,2)-2;
                end
                assignin('base', 'ordinato', ordinato);
                if(strcmp(name,'id-vds')==1 && strcmp(name,'id-vgs')==0)
                    writetable(ordinato,'id-vds.txt','Delimiter','\t','WriteRowNames',true);
                end
                if(strcmp(name,'id-vgs')==1 && strcmp(name,'id-vds')==0)
                    writetable(ordinato,'id-vgs.txt','Delimiter','\t','WriteRowNames',true);

                end
                if(strcmp(name,'id-vgs-2')==1)
                    writetable(ordinato,'id-vgs-2.txt','Delimiter','\t','WriteRowNames',true);

                end
            end
        end

        function ord(path)
            cd(path);
            k=dir();
            p={k(:).name};
            for t=3:length(p)
                h=cell2mat(p(1,t));
                cd(h);
                [~,name,~]=fileparts(pwd);
                k=dir();
                v={k(:).name};
                directories=strings;
                j=1;
                for i=1:width(v)
                    d=v{i};
                    s=d(1);

                    if strcmp(s,name(6))==1
                        directories(j,1)=convertCharsToStrings(d);
                        j=j+1;
                    end
                end

                for i=1:length(directories)
                    v=directories(i);
                    cd (v);
                    l=dir();
                    if numel(l)<=2
                        directories(i)='';
                    end
                    cd ..\;
                end

                directories=directories(~cellfun('isempty',directories));

                for i=1:length(directories)
                    cd (directories(i));
                    if isfile('id-vds.csv')
                        order.ordered('id-vds.csv',0,0.15,0.9);
                    end
                    if isfile('id-vgs.csv')
                        order.ordered('id-vgs.csv',0,0.15,0.9);
                    end
                    
                    if isfile('id-vgs-2.csv')
                        order.ordered('id-vgs-2.csv',0,0.01,0.10);
                    end
                    cd ..\;
                end

                cd ..\;
            end

        end

    end
end