%esempio di path='C:\Users\Emanuele\Desktop\Rumore-NMOS\600-180\N3'
function sovrapposizione(path)
cd(path);
k=dir();
p={k(:).name};
vect_noise_in=cell(1,4);
vect_noise_out=cell(1,4);
for t=3:length(p)

    h=cell2mat(p(1,t));
    if isfolder(h)
        cd(h);
        if strcmp(h,'100uA')
            file_data1 = importdata('noise_in.txt');
            file_data2 = importdata('noise_out.txt');
            vect_noise_in{1,2}=file_data1;
            vect_noise_out{1,2}=file_data2;
            cd ..\;
        end
        if strcmp(h,'50uA')
            file_data1 = importdata('noise_in.txt');
            file_data2 = importdata('noise_out.txt');
            vect_noise_in{1,1}=file_data1;
            vect_noise_out{1,1}=file_data2;
            cd ..\;
        end
        if strcmp(h,'250uA')
            file_data1 = importdata('noise_in.txt');
            file_data2 = importdata('noise_out.txt');
            vect_noise_in{1,3}=file_data1;
            vect_noise_out{1,3}=file_data2;
            cd ..\;
        end
        if strcmp(h,'500uA')
            file_data1 = importdata('noise_in.txt');
            file_data2 = importdata('noise_out.txt');
            vect_noise_in{1,4}=file_data1;
            vect_noise_out{1,4}=file_data2;
            cd ..\;
        end

    end
end
assignin("base","vect_noise_in",vect_noise_in);
assignin("base","vect_noise_out",vect_noise_out);

%noise out
for i=1:4
    loglog(vect_noise_out{1,i}(:,1),vect_noise_out{1,i}(:,2));
    
    hold all;
end
rumore.connected( cell2mat(vect_noise_out));
title('noise-out');
legend('I=50 uA', 'I=100 uA', 'I=250 uA','I=500 uA');
xlim([10^3, 10^8]);
axis square;
saveas(gcf, 'noise_out_sovr.png', 'png');
hold off;

% noise in
for i=1:4
    loglog(vect_noise_in{1,i}(:,1),vect_noise_in{1,i}(:,2));
    
    hold all;
end
rumore.connected(cell2mat(vect_noise_in));
title('noise-in');
legend('I=50 uA', 'I=100 uA', 'I=250 uA','I=500 uA');
xlim([10^3, 10^8]);
axis square;
xlabel('Frequency [Hz]');
ylabel('Noise Voltage Spectrum $\mathrm{[V/Hz^{1/2}]}$', 'Interpreter', 'latex');
saveas(gcf, 'noise_in_sovr.png', 'png');
hold off;
end