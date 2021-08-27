% Aggregate SMAP GPP and SM from daily to monthly
parpool local;

% Time setup
load ./data/SMAP_L4C_GPP_monthly.mat; clear GPP_monthly;
mo = [repmat(1:12,1,5) 1:11]';
yr = [repmat(2015,12,1)
    repmat(2016,12,1)
    repmat(2017,12,1)
    repmat(2018,12,1)
    repmat(2019,12,1)
    repmat(2020,11,1)];
nt = length(yr);

% Space setup
cd('D:\Data_Analysis\CSIF\CSIF_SMAP_TIF\');
fns = glob('*.tif');
temp = geotiffread(fns{1}); [ny,nx] = size(temp); clear temp;

% Loop through daily data and calculate monthly mean
CSIF_monthly = NaN(ny, nx, nt);
parfor i = 1:nt
    
    fn = sprintf('CSIF_%04d_%02d.tif',yr(i),mo(i));
    
    csif = double(geotiffread(fn));
    csif(csif < -10000) = NaN;
    CSIF_monthly(:,:,i) = csif;
    
end

cd('D:\Publications\Yan_et_al_SouthwestDrought2020');
save('./data/CSIF_monthly.mat', 'CSIF_monthly','yr','mo','lat','lon');

