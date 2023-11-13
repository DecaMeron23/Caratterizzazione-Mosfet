% esempio da runnare= C:\Users\Emanuele\Desktop\Rumore-NMOS\200-180
function mainrum(path)
cd(path);
k=dir();
p={k(:).name}
for t=3:length(p)
    h=cell2mat(p(1,t));
    cd(h);
    [~,name,~]=fileparts(pwd);
    k=dir();
    v={k(:).name}
    
    
    for i=3:width(v)
        d=v{i};
        cd (d);
        k=dir();
        s={k(:).name};
        fondo='';
        noise='';
        noise_out='';
        fdt='';
        for l=3:width(s)
            m=s{l};
            id1=m(1:5);
            id2=m(1:3);
            if strcmp(id1,'fondo')==1
                fondo=m;
            end
            if strcmp(id1,'noise')==1
                noise=m;
            end
            if strcmp(id2,'fdt')==1
                fdt=m;
            end
            


           
        end
          rumore.noise_out(fondo,noise);
          hold off
          
          if strcmp(m,'noise_out.txt')==1
                noise_out=m;
            end
          
            rumore.noise_in(noise_out,fdt);
            hold off
            cd ..\
       
       
    end

   

   
   cd ..\
end

end