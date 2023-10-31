function loadPackage_static(folderName, titleText)
    % folderName

    %% Create directory name string and title string
    text = titleText;
    mkdir([folderName, '\eps'])
    % Create figure directory
    % ~ = NOT->se non esiste,creo la directory figure
    if(~exist([folderName, '\eps'], 'dir'))
        mkdir([folderName, '\eps'])
    end
    
     %% Load pn.csv and save figures
%     pn = importFile_static([folderName, '\pn.csv'], 'id_vds_data');
%     plot_diodi(pn, text, folderName);
    
         %% Load id_vds.csv and save figures
    id_vds = importFile_static([folderName, '\id-vds.csv'], 'id_vds_data');
   plot_ID_VDS(id_vds, text, folderName);
  
    
   %% Calculate gds = d(I_d) / d(V_ds)
 %   gds = cell(1, 7);
 %   for i=1:7
 %       gds{i} = diff(id_vds(121*(i-1)+1 : 121*i, 3))./ diff(id_vds(121*(i-1)+1 : 121*i, 1));
 %   end
    
 %   plot_GDS(id_vds, gds, text, folderName);
    
    %% Load id_vgs.csv and save figures
    id_vgs = importFile_static([folderName, '\id-vgs.csv'], 'id_vgs_data');
    
    %plot_ID_VGS(id_vgs, text, folderName);
    
    plot_ID_VGS_log(id_vgs, text, folderName);
    
  %% Calculate gm = d(I_d) / d(V_gs)
  % and apply digital filter
  % creo un vettore di matrici
  %   gm = cell(1, 7);
  %   for i=1:7
  %       gm{i} = diff(id_vgs(151*(i-1)+1 : 151*i, 3))./ diff(id_vgs(151*(i-1)+1 : 151*i, 1));
  %       if length(gm{i})>=2
  %           for j=length(gm{i}):-1:2
  %               gm{i}(j) = (gm{i}(j) + gm{i}(j-1))/2;
  %           end
  %       end
  %   end
    
  %   plot_GM(id_vgs, gm, text, folderName);
    
   % plot_ID_VGS_sqrt(id_vgs, text, folderName);
   %  saveVthDataToWS(id_vgs, text, folderName);
end