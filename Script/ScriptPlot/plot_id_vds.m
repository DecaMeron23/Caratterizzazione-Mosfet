%function plot_id_vds(dati)

    dati = readmatrix("id-vds.txt");
    vds = .9 - dati(2:end , 1);

    vsg = 900:-150:0;
    id = dati(2:end , 7:5:end);

    id = abs(id);

    plot(vds, id)
    legend("$V_{SG} = " + vsg + " mV$", interpreter = "latex");
    title("$|I_D| - V_{SD}$", Interpreter="latex")
    xlabel("$V_{SD} [V]$", Interpreter="latex")
    ylabel("$|I_D| [A] $", Interpreter="latex");
    hold off;

    %cd plot\
    saveas(gcf, 'plot_id_vds.png', 'png');
    %cd ..
%end