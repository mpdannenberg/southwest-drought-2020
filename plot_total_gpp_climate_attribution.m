% Plot total study are GPP attribution with time series of annual GPP

%% Read in SMAP grid
load ./output/smap_gridded_anomaly_attribution;
GPP_obs(isnan(GPP_all)) = NaN; % need to compare apples-to-apples
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

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

%% Get boundaries of ecoregions
eco_bounds = zeros(size(ecoL2));
for i = 1:length(ecos)
    
    eco_bounds(ecoL2==ecos(i)) = i;
    
end
eco_bounds(isnan(GPP_obs)) = 0;

%% Make overall drought figure
h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 4.5 3.5];
clr = wesanderson('fantasticfox1');

% Annual GPP
load ./data/SMAP_L4C_GPP_monthly;
windowSize = 4;
b = ones(1,windowSize)/windowSize;
a = 1;
gpp = filter(b, a, GPP_monthly, [], 3);
clear b a windowSize;

a = 9000 * 9000 * (31 + 31 + 30 + 31) * (1 / 10^12);
gpp = a * gpp(:,:,mo==10);
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nansum(gpp_temp(~isnan(ecoL2))); end

subplot(3,1,1)
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total) mean(GPP_total)], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0])
yl = ylabel('Jul-Oct GPP (Tg C)', 'FontSize',9);
yl.Position(1) = yl.Position(1)-0.05;
ylim = get(gca,'YLim');
text(2015.1, ylim(2), 'a', 'FontSize',12, 'FontWeight','bold','VerticalAlignment','bottom')


% Attribution
subplot(3,1,[2 3])
plot([0 6],[nansum(a*GPP_obs(~isnan(ecoL2))) nansum(a*GPP_obs(~isnan(ecoL2)))], 'k-', 'LineWidth',2)
text(3, nansum(a*GPP_obs(~isnan(ecoL2))), 'SMAP L4C total anomaly','FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
hold on;
bar(1, nansum(a*GPP_all(~isnan(ecoL2))), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nansum(a*GPP_par(~isnan(ecoL2))), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nansum(a*GPP_sm(~isnan(ecoL2))), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nansum(a*GPP_tair(~isnan(ecoL2))), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nansum(a*GPP_vpd(~isnan(ecoL2))), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nansum(a*GPP_all_low(~isnan(ecoL2))) nansum(a*GPP_all_high(~isnan(ecoL2)))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nansum(a*GPP_par_low(~isnan(ecoL2))) nansum(a*GPP_par_high(~isnan(ecoL2)))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nansum(a*GPP_sm_low(~isnan(ecoL2))) nansum(a*GPP_sm_high(~isnan(ecoL2)))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nansum(a*GPP_tair_low(~isnan(ecoL2))) nansum(a*GPP_tair_high(~isnan(ecoL2)))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nansum(a*GPP_vpd_low(~isnan(ecoL2))) nansum(a*GPP_vpd_high(~isnan(ecoL2)))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],'XTick',1:5,...
        'XLim',[0.25 5.75], 'FontSize',9, 'YLim',[-110 10],'YTick',-100:20:0)
ylabel('Jul-Oct GPP anomaly (Tg C)', 'FontSize',9)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
% ax = gca;
% ax.Position(3) = 0.55;
text(0.35, 0, 'b', 'FontSize',12, 'FontWeight','bold','VerticalAlignment','bottom')

h1 = axes('Parent', gcf, 'Position', [0.75 0.13 0.18 0.3]);
set(h1, 'Color','w')
p = pie(-1*fliplr([nansum(a*GPP_par(~isnan(ecoL2))) nansum(a*GPP_sm(~isnan(ecoL2))) nansum(a*GPP_tair(~isnan(ecoL2))) nansum(a*GPP_vpd(~isnan(ecoL2)))]), zeros(1,4));
colormap(gca, flipud([sqrt(clr(4,:)); clr(3,:); clr(1,:); clr(2,:)]))
set(findobj(p,'Type','text'), 'FontSize',7);

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/smap-gpp-total-regional-attribution.png')
print('-dtiff','-f1','-r300','./output/smap-gpp-total-regional-attribution.tif')
close all;


