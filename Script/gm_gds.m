function  gm = gm_gds( id , vgs_vds)
% funzione che puo essere utilizzata sia per calcolare la gm che la gds,
% per calcolare la gds passare come parametro vds al posto di vgs
    gm1 = zeros(size(id));
    gm2 = gm1;

    for i=1:width(id)
        gm1(:,i) = gradient(id(:,i)) ./ gradient(vgs_vds);
    end
    
    gm2(1,:) = gm1(1,:);
    
    for i=1:width(id)
        gm2(2:end,i) = gradient(id(1:end-1,i))./gradient(vgs_vds(2:end));
    end
    
    gm = (gm1+gm2)/2;
    
    for i=1:width(gm)
        gm(:,i) = smooth(gm(:,i));
    end
end