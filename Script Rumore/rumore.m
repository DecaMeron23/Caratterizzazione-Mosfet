
classdef rumore
    methods(Static)
        function connected(matrix)
            vect=[];
            trigger =false;
            for i=1:height(matrix)
               
                if  i >=2 && matrix(i,2)==0 && trigger==false
                    vect(1,1)=matrix(i-1,1);
                    vect(1,2)=matrix(i-1,2);
                    trigger=true;
                end

                if matrix(i,2)~=0 && trigger==true
                    vect(2,1)=matrix(i,1);
                    vect(2,2)=matrix(i,2);
                    line(vect(:,1),vect(:,2));
                    set(gca, 'YMinorTick', 'on', 'YScale', 'log')
                    set(gca, 'XMinorTick', 'on', 'XScale', 'log')
                    hold on;
                    vect=[];
                    trigger=false;
                end
            end
            
        end

        function noise_out (file1,file2)
            tipo1=extractBefore(file1,'_');
            tipo2=extractBefore(file2,'_');
            if strcmp (tipo1,'fondo')==1
                x=readtable(file1,VariableNamingRule="preserve");
                fondo=table2array(x);
            end
            assignin("base","fondo",fondo);
            if strcmp (tipo2,'noise')==1
                y=readtable(file2,VariableNamingRule="preserve");
                noise=table2array(y);
            end
            assignin("base","noise",noise);
            if height(noise)==height(fondo)
                noise_out=zeros(height(noise),2);
                noise_out(:,1)=noise(:,1);

                for i=1:height(noise)
                    if  noise(i,2)>fondo(i,2)
                        x=noise(i,2)^2;
                        y=fondo(i,2)^2;
                        noise_out(i,2)=sqrt(x-y);
                    end
                end
            end
            assignin("base","noise_out",noise_out);
            loglog(noise_out(:,1),noise_out(:,2));
            xlabel('Frequency [Hz]');
            ylabel('Noise Voltage Spectrum ')
            xlim([10^3, 10^8]);
            hold on;
            
            rumore.connected(noise_out);
            %noise_out_nozeroes=[];
            %j=1;
             %    for i=1:height(noise_out)
              %      if noise_out(i,2)~=0 
               %         noise_out_nozeroes(j,:)=noise_out(i,:);
                %        j=j+1;
                 %   end
                 %end
                 %writematrix(noise_out_nozeroes,'noise_out_nozeroes.txt','delimiter', ' ');
            
            %saveas(gcf, 'noise_out.png', 'png');
            writematrix(noise_out,'noise_out.txt','delimiter', ' ');
            
        end
        function noise_in(first,second)
            primo=extractBefore(first,'.');
            secondo=extractBefore(second,'_');
            terzo=extractAfter(second,'_');
            if strcmp (primo,'noise_out')==1
                x=readtable(first,VariableNamingRule="preserve");
                noise_out=table2array(x);
            end
            assignin("base","noise_out",noise_out);
            if strcmp (secondo,'fdt')==1
                y=readtable(second,VariableNamingRule="preserve");
                fdt=table2array(y);
            end
            assignin("base","fdt",fdt);
            noise_in=zeros(height(fdt),2);
            noise_in(:,1)=fdt(:,1);
            for i=1:height(fdt)
                den=10^(fdt(i,2)/20);
                noise_in(i,2)=noise_out(i,2)/den;
            end
            assignin("base","noise_in",noise_in);
            %noise_in(:,2)=medfilt1(noise_in(:,2),2);
            writematrix(noise_in,'noise_in.txt','delimiter', ' ')
            loglog(noise_in(:,1),noise_in(:,2));
            xlabel('Frequency [Hz]');
            ylabel('Noise Voltage Spectrum ')
            hold on;
            rumore.connected(noise_in);
            xlim([10^3, 10^8]);
            saveas(gcf, 'noise_in.png', 'png');
            
            
        end
        function fdt (file)
            k=extractBefore(file,'_');
            if strcmp (k,'fdt')==1
                y=readtable(file,VariableNamingRule="preserve");
                loglog(y(:,1),y(:,2));
                xlabel('Frequency [Hz]');
                ylabel('Noise Voltage Spectrum ')
            end
        end
        function fondo (file)
            k=extractBefore(file,'_');
            if strcmp (k,'fondo')==1
                y=readtable(file,VariableNamingRule="preserve");
                loglog(y(:,1),y(:,2));
                xlabel('Frequency [Hz]');
                ylabel('Noise Voltage Spectrum ')
            end
        end
    end
end