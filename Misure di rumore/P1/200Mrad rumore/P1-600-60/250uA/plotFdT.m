FdT = readmatrix("fdt_P1_600_60_250uA_200Mrad.txt");
x=FdT(1,:);
y = FdT(2,:)
xlim([10^3,10^8]);
loglog(x,y)