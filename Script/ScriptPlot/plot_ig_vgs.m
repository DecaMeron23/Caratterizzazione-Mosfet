function plot_ig_vgs(mod_id , vgs , type , folders)
    %% facciamo il plot
    semilogy(vgs, mod_id)
    
    if(type == 'P')
        name_vg = "V_{SG}";
    elseif(type == 'N')
        name_vg = "V_{GS}";
    end

    xlabel("$" + name_vg + "[V]$" , Interpreter="latex");
    ylabel("$|I_D|[A]$" , Interpreter="latex");
    legend(folders , Location="best");

    %% salviamo il plot
    cd plot\
        saveas(gcf , "plot_mod_ig_vgs" , 'eps');
        saveas(gcf , "plot_mod_ig_vgs" , 'png');
    cd ..
end