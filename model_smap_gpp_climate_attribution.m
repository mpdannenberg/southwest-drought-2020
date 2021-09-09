% Do climate attribution for western U.S. SMAP GPP
parpool local;

years = 2015:2020;
warning('off','all');
nsims = 100;

% Load SMAP GPP and SM
load ./data/SMAP_L4_SM_monthly.mat;
load ./data/SMAP_L4C_GPP_monthly.mat;
[ny, nx, ~] = size(GPP_monthly);

% Pad with NaNs for months with no SMAP data
GPP_monthly = cat(3, NaN(ny,nx,3), GPP_monthly, NaN(ny,nx,2));
SurfSM_monthly = cat(3, NaN(ny,nx,3), SurfSM_monthly, NaN(ny,nx,2));
RootSM_monthly = cat(3, NaN(ny,nx,3), RootSM_monthly, NaN(ny,nx,2));
Tsoil_monthly = cat(3, NaN(ny,nx,3), Tsoil_monthly, NaN(ny,nx,2));
yr = [repmat(2015,3,1); yr; repmat(2020,2,1)];
mo = [[1:3]'; mo; [11:12]'];

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
GPP_obs = NaN(ny,nx);
GPP_r2 = NaN(ny,nx);
GPP_all = NaN(ny,nx);
GPP_par = NaN(ny,nx);
GPP_sm = NaN(ny,nx);
GPP_tair = NaN(ny,nx);
GPP_vpd = NaN(ny,nx);
GPP_all_ens = NaN(ny,nx,nsims);
GPP_par_ens = NaN(ny,nx,nsims);
GPP_sm_ens = NaN(ny,nx,nsims);
GPP_tair_ens = NaN(ny,nx,nsims);
GPP_vpd_ens = NaN(ny,nx,nsims);
parfor i = 1:ny
    for j = 1:nx
        
        y = reshape(squeeze(GPP_monthly(i,j,:)), 12, []);
        rg = reshape(squeeze(Rg_monthly(i,j,:)), 12, []);
        sm = reshape(squeeze(RootSM_monthly(i,j,:)), 12, []);
        tmx = reshape(squeeze(Tmax_monthly(i,j,:)), 12, []);
        tmn = reshape(squeeze(Tmin_monthly(i,j,:)), 12, []);
        vpd = reshape(squeeze(VPD_monthly(i,j,:)), 12, []);
        tmean = (tmn + tmx) / 2;
        
        if sum(sum(tmean > 0)) >= 20 % Check that there's a reasonable amount of data for the training set
            
            X = cat(3, rg, sm, tmean, vpd);
            [mdl, mdl_stats] = anomaly_attribution(y, X, 'nsims',100,'nlags',1,...
                'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm',...
                'modelspec','purequadratic','trainset',(tmean>0), 'baseyrs',(years>=2015 & years<=2019));
            
            GPP_r2(i,j) = mean(mdl_stats.R2_Validation);
            GPP_obs(i,j) = mean(mdl.GPP_Obs(idx) - mdl.GPP_Avg(idx));
            GPP_all(i,j) = mean(mdl.GPP_All(idx) - mdl.GPP_Avg(idx));
            GPP_par(i,j) = mean(mdl.GPP_PAR(idx) - mdl.GPP_Avg(idx));
            GPP_sm(i,j) = mean(mdl.GPP_SM(idx) - mdl.GPP_Avg(idx));
            GPP_tair(i,j) = mean(mdl.GPP_Tair(idx) - mdl.GPP_Avg(idx));
            GPP_vpd(i,j) = mean(mdl.GPP_VPD(idx) - mdl.GPP_Avg(idx));
            
            GPP_all_ens(i,j,:) = mean(mdl_stats.GPP_All(idx, :));
            GPP_par_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 1));
            GPP_sm_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 2));
            GPP_tair_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 3));
            GPP_vpd_ens(i,j,:) = mean(mdl_stats.BootSims(idx, :, 4));
            
        end
        
    end
end
toc

save('smap_gridded_anomaly_attribution.mat', 'GPP_obs','GPP_all','GPP_r2','GPP_par','GPP_sm','GPP_tair','GPP_vpd','GPP_all_ens','GPP_par_ens','GPP_sm_ens','GPP_tair_ens','GPP_vpd_ens','lat','lon', '-v7.3');

%% Write out geotiffs
% Get spatial reference
[~, R] = geotiffread('./data/Gridmet_Monthly_HotDrought/srad_2015.tif');

% Write data
geotiffwrite('GPP_obs.tif', GPP_obs, R);
geotiffwrite('GPP_all.tif', GPP_all, R);
geotiffwrite('GPP_r2.tif', GPP_r2, R);
geotiffwrite('GPP_par.tif', GPP_par, R);
geotiffwrite('GPP_sm.tif', GPP_sm, R);
geotiffwrite('GPP_tair.tif', GPP_tair, R);
geotiffwrite('GPP_vpd.tif', GPP_vpd, R);


