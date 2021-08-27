% Aggregate SMAP GPP and SM from daily to monthly
parpool local;

% Time setup
mo = [4:12 repmat(1:12,1,4) 1:10]';
yr = [repmat(2015,9,1)
    repmat(2016,12,1)
    repmat(2017,12,1)
    repmat(2018,12,1)
    repmat(2019,12,1)
    repmat(2020,10,1)];
nt = length(yr);

% Space setup
latlim = [28 49];
lonlim = [-125 -100];

cd('R:\data archive\SMAP_Carbon');
fns = glob('*.h5');

glat = h5read(fns{1}, '/GEO/latitude');
glon = h5read(fns{1}, '/GEO/longitude');

latidx = find(glat(1,:) >= min(latlim) & glat(1,:) <= max(latlim)); ny = length(latidx);
lonidx = find(glon(:,1) >= min(lonlim) & glon(:,1) <= max(lonlim)); nx = length(lonidx);

% Loop through daily data and calculate monthly mean
GPP_monthly = NaN(ny, nx, nt);
parfor i = 1:nt
    
    fns = sprintf('SMAP_L4_C_mdl_%04d%02d*.h5',yr(i),mo(i));
    fns = glob(fns);
    
    GPP_daily = NaN(ny, nx, length(fns));
    
    for j = 1:length(fns)
        
        gpp = double(h5read(fns{j}, '/GPP/gpp_mean')); gpp(gpp==-9999) = NaN;
        %qa = double(h5read(fns{j}, '/QA/carbon_model_bitflag')); 
        %qa_gpp = bitget(qa, 2);
        gpp = gpp(lonidx, latidx)';
        GPP_daily(:,:,j) = gpp;
        
    end
    
    GPP_monthly(:,:,i) = nanmean(GPP_daily, 3);
    
end

cd('D:\Publications\Yan_et_al_SouthwestDrought2020');

lat = glat(1,latidx)';
lon = glon(lonidx,1);

save('./data/SMAP_L4C_GPP_monthly.mat', 'GPP_monthly','yr','mo','lat','lon');

