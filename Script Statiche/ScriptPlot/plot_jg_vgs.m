function plot_jg_vgs(mod_jg , vgs , type , folders)
    %% facciamo il plot

    for i = 1 : width(mod_jg) 
        mod_jg(i) = smooth(mod_jg(i));
    end
    semilogy(vgs, mod_jg)
    
    if(type == 'P')
        name_vg = "V_{SG}";
    elseif(type == 'N')
        name_vg = "V_{GS}";
    end

    xlabel("$" + name_vg + "[V]$" , Interpreter="latex");
    ylabel("$|J_G|[A/cm^2]$" , Interpreter="latex");
    legend(folders , Location="best");

    %% salviamo il plot
    cd plot\
        saveas(gcf , "plot_mod_jg_vgs" , 'eps');
        saveas(gcf , "plot_mod_jg_vgs" , 'png');
    cd ..
end