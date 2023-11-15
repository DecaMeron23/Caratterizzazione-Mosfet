%function plot_id_vds(dati)
    dati = readmatrix("id-vds.txt");
    vds = dati(2:end , 1);
    vsg = 900:-150:0;
    id = dati(2:end , 7:5:end);

    hold on
    plot(vds, id)
    legend("$V_{SG} = " + vsg + " mV$", interpreter = "latex");
    title("$I_D - V_{DS}$", Interpreter="latex")
    xlabel("$V_{DS} [V]$", Interpreter="latex")
    ylabel("$I_D [A] $", Interpreter="latex");
    hold off;
    saveas(gcf, 'plot_id_vds.png', 'png');
%end