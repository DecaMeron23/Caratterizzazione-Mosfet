%loadPackage_static('n', 1000, 130, 0)
%close all
%plotVthData(data, id_sqrt)
%calculateVth(data, id_sqrt, titleText, folderName)
%clear all
%clc

%primo parametro=nome della cartella dove sono contenuti i grafici
%secondo parametro=nome che voglio dare al plot
function auto(path)
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
        a=name(6:9);
        b=convertStringsToChars(extractBetween(directories(i),4,6));
        c=convertStringsToChars(extractAfter(directories(i),7));
        loadPackage_static(convertStringsToChars(directories(i)),strcat(a,' W',b,'L',c));
        cd (directories(i))
        if ~exist("\eps", 'dir')
            mkdir eps;
        end
        %if isfile('id-vgs-2.txt')
            %ID_VGS_2('id-vgs-2.txt',strcat(a,' W',b,'L',c));
        %end
        
        if isfile('id-vgs.txt')
            gm_gds('id-vgs.txt',strcat(a,' W',b,'L',c),convertStringsToChars(directories(i)),false); % false scala lineare
            %gm_gds('id-vgs.txt',strcat(a,'
            %W',b,'L',c),convertStringsToChars(directories(i)),true); %true
            %scala logaritmica
        end
        
            gm_gds('id-vds.txt',strcat(a,' W',b,'L',c),convertStringsToChars(directories(i)),false);
        
        %questa era commentata
       
            gm_id('gm-vgs.txt','id-vgs.txt',strcat(a,' W',b,'L',c),convertStringsToChars(directories(i)));
        cd ..\
    end
    
  

    cd ..\;
   
end

end








