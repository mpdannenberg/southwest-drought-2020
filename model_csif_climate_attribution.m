% Do climate attribution for western U.S. SMAP GPP
parpool local;

years = 2015:2020;
warning('off','all');
nsims = 100;

% Load SMAP GPP and SM
load ./data/SMAP_L4_SM_monthly.mat;
load ./data/CSIF_monthly.mat;
[ny, nx, ~] = size(CSIF_monthly);

% Pad with NaNs for months with no SMAP data
CSIF_monthly = cat(3, CSIF_monthly, NaN(ny,nx,1));
SurfSM_monthly = cat(3, NaN(ny,nx,3), SurfSM_monthly, NaN(ny,nx,2));
RootSM_monthly = cat(3, NaN(ny,nx,3), RootSM_monthly, NaN(ny,nx,2));
Tsoil_monthly = cat(3, NaN(ny,nx,3), Tsoil_monthly, NaN(ny,nx,2));
yr = [yr; 2020];
mo = [mo; 12];

% Load and organize Gridmet Tmin, Tmax, VPD, SRAD
Tmin_monthly = NaN(ny, nx, 12*length(years));
Tmax_monthly = NaN(ny, nx, 12*length(years));
VPD_monthly = NaN(ny, nx, 12*length(years));
Rg_monthly = NaN(ny, nx, 12*length(years));
for i = 1:length(years)
    
    % Rg (W m-2)
    temp = double(geotiffread(['./data/Gridmet_Monthly_HotDrought/srad_',num2str(years(i)),'.tif']));
    temp(temp < 0) = NaN;
    Rg_monthly(:,:,yr == years(i)) = temp(:,:,:);
    
    % Tmin (K)
    temp = double(geotiffread(['./data/Gridmet_Monthly_HotDrought/tmmn_',num2str(years(i)),'.tif']));
    temp(temp < 0) = NaN;
    Tmin_monthly(:,:,yr == years(i)) = temp(:,:,:)-273.15;
    
    % Tmax (K)
    temp = double(geotiffread(['./data/Gridmet_Monthly_HotDrought/tmmx_',num2str(years(i)),'.tif']));
    temp(temp < 0) = NaN;
    Tmax_monthly(:,:,yr == years(i)) = temp(:,:,:)-273.15;
    
    % VPD (kPa)
    temp = double(geotiffread(['./data/Gridmet_Monthly_HotDrought/vpd_',num2str(years(i)),'.tif']));
    temp(temp < 0) = NaN;
    VPD_monthly(:,:,yr == years(i)) = temp(:,:,:);
    
end
clear i temp;

% Loop through each grid cell and run attribution
idx = yr == 2020 & mo>=7 & mo<=10;

tic
CSIF_obs = NaN(ny,nx);
CSIF_r2 = NaN(ny,nx);
CSIF_all = NaN(ny,nx);
CSIF_par = NaN(ny,nx);
CSIF_sm = NaN(ny,nx);
CSIF_tair = NaN(ny,nx);
CSIF_vpd = NaN(ny,nx);
CSIF_all_ens = NaN(ny,nx,nsims);
CSIF_par_ens = NaN(ny,nx,nsims);
CSIF_sm_ens = NaN(ny,nx,nsims);
CSIF_tair_ens = NaN(ny,nx,nsims);
CSIF_vpd_ens = NaN(ny,nx,nsims);
parfor i = 1:ny
    for j = 1:nx
        
        y = reshape(squeeze(CSIF_monthly(i,j,:)), 12, []);
        rg = reshape(squeeze(Rg_monthly(i,j,:)), 12, []);
        sm = reshape(squeeze(RootSM_monthly(i,j,:)), 12, []);
        tmx = reshape(squeeze(Tmax_monthly(i,j,:)), 12, []);
        tmn = reshape(squeeze(Tmin_monthly(i,j,:)), 12, []);
        vpd = reshape(squeeze(VPD_monthly(i,j,:)), 12, []);
        tmean = (tmn + tmx) / 2;
        
        if sum(sum(tmean > 0)) >= 20 % Check that there's a reasonable amount of data for the training set
            
            X = cat(3, rg, sm, tmean, vpd);
            [mdl, mdl_stats] = anomaly_attribution(y, X, 'nsims',100,'nlags',1,...
                'yname','CSIF', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm',...
                'modelspec','purequadratic','trainset',(tmean>0), 'baseyrs',(years>=2015 & years<=2019));
            
            CSIF_r2(i,j) = mean(mdl_stats.R2_Validation);
            CSIF_obs(i,j) = mean(mdl.CSIF_Obs(idx) - mdl.CSIF_Avg(idx));
            CSIF_all(i,j) = mean(mdl.CSIF_All(idx) - mdl.CSIF_Avg(idx));
            CSIF_par(i,j) = mean(mdl.CSIF_PAR(idx) - mdl.CSIF_Avg(idx));
            CSIF_sm(i,j) = mean(mdl.CSIF_SM(idx) - mdl.CSIF_Avg(idx));
            CSIF_tair(i,j) = mean(mdl.CSIF_Tair(idx) - mdl.CSIF_Avg(idx));
            CSIF_vpd(i,j) = mean(mdl.CSIF_VPD(idx) - mdl.CSIF_Avg(idx));
            
            CSIF_all_ens(i,j,:) = mean(mdl_stats.CSIF_All(idx, :));
            CSIF_par_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 1));
            CSIF_sm_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 2));
            CSIF_tair_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 3));
            CSIF_vpd_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 4));
            
        end
        
    end
end
toc

save('csif_gridded_anomaly_attribution.mat', 'CSIF_obs','CSIF_all','CSIF_r2','CSIF_par','CSIF_sm','CSIF_tair','CSIF_vpd','CSIF_all_ens','CSIF_par_ens','CSIF_sm_ens','CSIF_tair_ens','CSIF_vpd_ens','lat','lon', '-v7.3');

%% Write out geotiffs
% Get spatial reference
[~, R] = geotiffread('./data/Gridmet_Monthly_HotDrought/srad_2015.tif');

% Write data
geotiffwrite('CSIF_obs.tif', CSIF_obs, R);
geotiffwrite('CSIF_all.tif', CSIF_all, R);
geotiffwrite('CSIF_r2.tif', CSIF_r2, R);
geotiffwrite('CSIF_par.tif', CSIF_par, R);
geotiffwrite('CSIF_sm.tif', CSIF_sm, R);
geotiffwrite('CSIF_tair.tif', CSIF_tair, R);
geotiffwrite('CSIF_vpd.tif', CSIF_vpd, R);


