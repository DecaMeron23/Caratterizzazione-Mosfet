classdef EstrazioneDati
    
    methods (Static)
    
        function [vgs , id , vds] = estrazione_dati_vgs(file , type)
        % Funzione che estrae i dati da file, in input si da il nome del file e il
        % tipo di dispositivo es: 'P'
        % in output restituisce la prima colonna del file,che consideriamo "vgs", se il dispositivo è P restituisce
        % "Vsg" (Vs = 0.9V), come secondo output restituisce una matrice id, con le
        % correnti al variare di vds (terzo output), se il dispositivo è P
        % restituisce l'abs di "id"
        % 
            
            dati = readmatrix(file);
            vg = dati(: , 1);
            
            % per i dispositivi P consideriamo il -Vgs == Vsg
            if(type == 'P')
                vgs = vg - 0.9;
                vgs = -(vgs);
            elseif(type == 'N')
                vgs = vg;
            end
            
            
            COLONNE_ID = 2:5:width(dati); 
            id = dati(: , COLONNE_ID);
            
            if(type == 'P')
                id = fliplr(id);
                id = abs(id);
            end
            
            id = id(: , 2:end); % escludiamo lo zero
            
            %per i dispositivi P si intende |Vds|
            if(length(COLONNE_ID) == 7) % file
                vds = 150 : 150 : 900;
            elseif(length(COLONNE_ID) == 11) % file _2.txt
                vds = 10 : 10 : 100; 
            end
        end

        function [vds , id , vgs] = estrazione_dati_vds(file , type)
        % Funzione che estrae i dati da file, in input si da il nome del file e il
        % tipo di dispositivo es: 'P'
        % in output restituisce la prima colonna del file,che consideriamo "vds", se il dispositivo è P restituisce
        % il modulo di "Vds", come secondo output restituisce una matrice id, con le
        % correnti al variare di Vgs (terzo output , se P |Vgs|), se il dispositivo è P
        % restituisce l'abs di "id"
        % 
            
            dati = readmatrix(file);
            vd = dati(: , 1);
            
            % per i dispositivi P consideriamo il -Vgs == Vsg
            if(type == 'P')
                vds = vd - 0.9;
                vds = abs(vds);
            elseif(type == 'N')
                vds = vd;
            end
            
            
            COLONNE_ID = 2:5:width(dati); 
            id = dati(: , COLONNE_ID);
        
            if(type == 'P')
                id = fliplr(id);
                id = abs(id);
            end
            
            id = id(: , 2:end); % escludiamo lo zero
        
            %per i dispositivi P si intende |Vgs|
            if(length(COLONNE_ID) == 7) % file
                vgs = 150 : 150 : 900;
            elseif(length(COLONNE_ID) == 11) % file _2.txt
                vgs = 10 : 10 : 100; 
            end
        end

        %% Estrazione dati ig
        function  [mod_ig , vgs] = estrazione_dati_ig_vgs(file , type)
            
            dati = readmatrix(file);
            vg = dati(: , 1);
            
            % per i dispositivi P consideriamo il -Vgs == Vsg
            if(type == 'P')
                vgs = vg - 0.9;
                vgs = -(vgs);
            elseif(type == 'N')
                vgs = vg;
            end
        
            if(type == 'P')
                COLONNA_IG_VDS_0 = 33;
            elseif(type == 'N')
                COLONNA_IG_VDS_0 = 3;
            end
            
            % prendiamo la |ig| a vds = 0
            mod_ig = abs(dati(: , COLONNA_IG_VDS_0));
            
        end
    end
end