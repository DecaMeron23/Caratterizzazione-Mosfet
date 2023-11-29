classdef tangente
    methods(Static)
        function t= tan (vector_x,vector_y,col0)
            %colonna di cui voglio i dati
            %plotto i dati
            %% Taglio i dati compresi tra 10^-9 e 10^-5
            x=vector_x(:,col0);
            y=vector_y(:,col0);

            exponents=[];

            for i=1:length(x)
                exponents(i)=log10(x(i));
            end

            position=1;
            final_x=[];
            final_y=[];

            for i=1:length(exponents)
                if exponents(i)>=-9 && exponents(i)<=-5
                    final_x(position)=x(i);
                    final_y(position)=y(i);
                    position=position+1;
                end
            end

            assignin("base","final_x",final_x);
            assignin("base","final_y",final_y);

   
            set(gca, 'XMinorTick', 'on','XScale','log')
            axis([10^-9 10^-5 1 100])


            semilogx(final_x,final_y);

            hold all;

            %% Creo retta orizzontale che passa per il punto più alto
            max=0.0;
            for i=1:length(final_y)
                if final_y(i)>= max
                    max=final_y(i);
                end
            end
            % plotto la retta
            plot([10^-9 10^-5],[max max],'--');
            hold all;
            %% creo retta con slope -0.5
            m=0.5;
            xi=[-9:0.001:-5];
            yi=-m.*xi;
            xs=10.^xi;   
            plot(xs,yi,'--');
        end
            
        
  

        end

        
end

   
    
