% Plot GPP anomaly attribution by land cover type
alphabet = 'abcdefghijklmnopqrstuvwxyz';

%% Read in SMAP grid
load ./output/smap_gridded_anomaly_attribution;
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

%% Calculate CIs for each pixel
GPP_all_low = quantile(GPP_all_ens, 0.025, 3);
GPP_par_low = quantile(GPP_par_ens, 0.025, 3);
GPP_sm_low = quantile(GPP_sm_ens, 0.025, 3);
GPP_tair_low = quantile(GPP_tair_ens, 0.025, 3);
GPP_vpd_low = quantile(GPP_vpd_ens, 0.025, 3);
GPP_all_high = quantile(GPP_all_ens, 0.975, 3);
GPP_par_high = quantile(GPP_par_ens, 0.975, 3);
GPP_sm_high = quantile(GPP_sm_ens, 0.975, 3);
GPP_tair_high = quantile(GPP_tair_ens, 0.975, 3);
GPP_vpd_high = quantile(GPP_vpd_ens, 0.975, 3);

%% Read in land cover data
load ./data/mcd12c1.mat;
lc = {'Forest','Shrubland','Savanna','Grassland','Cropland (west)','Cropland (east)'};
biome(biome==5 & repmat(lon',length(lat),1)>-110) = 6;
biome(igbp==8) = 1;
biome(biome==0) = NaN;

%% Add EcoRegions 
ecoL3 = shaperead('D:\Data_Analysis\EcoRegions\NA_CEC_Eco_Level3_GEO.shp', 'UseGeoCoords',true);
ecoL1_code = cellfun(@str2double, {ecoL3.NA_L1CODE});
idx = ecoL1_code == 6 | ecoL1_code == 7 | (ecoL1_code >=9 & ecoL1_code <=13);
ecoL3 = ecoL3(idx);
ecoL2_code = cellfun(@str2double, {ecoL3.NA_L2CODE});
clear idx ecoL1_code;

[LON, LAT] = meshgrid(lon, lat);
LatLon = [reshape(LAT, [], 1) reshape(LON, [], 1)];
ecoL2 = NaN(size(LatLon,1),1);

for i = 1:length(ecoL3)
    
    [IN, ON] = inpolygon(LatLon(:,1), LatLon(:,2), ecoL3(i).Lat, ecoL3(i).Lon);
    ecoL2(IN | ON) = str2double(ecoL3(i).NA_L2CODE);
    
end
ecoL2 = reshape(ecoL2, size(LAT, 1), size(LAT, 2));
clear LON LAT LatLon i IN ON;

%% Remove small ecoregions or regions outside main domain or regions outside droughtiest part
ecoL2(ecoL2 == 13.2) = NaN;
ecoL2(ecoL2 == 9.2) = NaN;
ecoL2(ecoL2 == 9.6) = NaN;
ecoL2(ecoL2 == 6.2) = NaN;
ecoL2(ecoL2 == 7.1) = NaN;
ecoL2(ecoL2 == 9.3) = NaN;
ecos = unique(ecoL2(~isnan(ecoL2)));
idx = ismember(ecoL2_code, ecos);
ecoL3 = ecoL3(idx);

%% Add bar plots by land cover
nrows = 2;
ncols = 3;

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 4];
ax = tight_subplot(nrows, ncols, [0.05 0.02], [0.12 0.05], [0.1 0.05]);

clr = wesanderson('fantasticfox1');

for i = 1:length(lc)
    
    axes(ax(i))
    
    plot([0 6],[nanmean(GPP_obs(biome==i & ~isnan(ecoL2))) nanmean(GPP_obs(biome==i & ~isnan(ecoL2)))], 'k-', 'LineWidth',2)
    if i ~= 5
        text(4, nanmean(GPP_obs(biome==i & ~isnan(ecoL2))), 'observed','FontSize',8,'VerticalAlignment','bottom')
    else
        text(4, nanmean(GPP_obs(biome==i & ~isnan(ecoL2))), 'observed','FontSize',8,'VerticalAlignment','top')
    end
    hold on;
    bar(1, nanmean(GPP_all(biome==i & ~isnan(ecoL2))), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
    bar(2, nanmean(GPP_par(biome==i & ~isnan(ecoL2))), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
    bar(3, nanmean(GPP_sm(biome==i & ~isnan(ecoL2))), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
    bar(4, nanmean(GPP_tair(biome==i & ~isnan(ecoL2))), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
    bar(5, nanmean(GPP_vpd(biome==i & ~isnan(ecoL2))), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
    plot([1 1], [nanmean(GPP_all_low(biome==i & ~isnan(ecoL2))) nanmean(GPP_all_high(biome==i & ~isnan(ecoL2)))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
    plot([2 2], [nanmean(GPP_par_low(biome==i & ~isnan(ecoL2))) nanmean(GPP_par_high(biome==i & ~isnan(ecoL2)))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
    plot([3 3], [nanmean(GPP_sm_low(biome==i & ~isnan(ecoL2))) nanmean(GPP_sm_high(biome==i & ~isnan(ecoL2)))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
    plot([4 4], [nanmean(GPP_tair_low(biome==i & ~isnan(ecoL2))) nanmean(GPP_tair_high(biome==i & ~isnan(ecoL2)))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
    plot([5 5], [nanmean(GPP_vpd_low(biome==i & ~isnan(ecoL2))) nanmean(GPP_vpd_high(biome==i & ~isnan(ecoL2)))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
    hold off;
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
            'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.75 0.2])
        
    if i > (nrows-1)*ncols
        set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
        xtickangle(-20)
    else
        set(gca, 'XTickLabel','')
    end
    
    if rem(i, ncols) == 1
        ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',7)
    else
        set(gca, 'YTickLabel','')
    end
    
    ttl = title(lc{i}, 'FontSize',10);
    ttl.Position(2) = 0.15;
    
    text(0.5, 0.2, alphabet(i), 'FontSize',11, 'FontWeight','bold');
    
end

% axes(ax(6))
% box off;
% set(gca, 'YColor','w', 'XColor','w');

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/smap-gpp-lc-attribution.png')
print('-dtiff','-f1','-r300','./output/smap-gpp-lc-attribution.tif')
close all;

