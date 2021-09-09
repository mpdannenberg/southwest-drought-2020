% Show anomalies by ecoregion

%% Read in CSIF grid
load ./output/csif_gridded_anomaly_attribution;
CSIF_obs(isnan(CSIF_all)) = NaN; % need to compare apples-to-apples
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Calculate CIs for each pixel
CSIF_all_low = quantile(CSIF_all_ens, 0.025, 3);
CSIF_par_low = quantile(CSIF_par_ens, 0.025, 3);
CSIF_sm_low = quantile(CSIF_sm_ens, 0.025, 3);
CSIF_tair_low = quantile(CSIF_tair_ens, 0.025, 3);
CSIF_vpd_low = quantile(CSIF_vpd_ens, 0.025, 3);
CSIF_all_high = quantile(CSIF_all_ens, 0.975, 3);
CSIF_par_high = quantile(CSIF_par_ens, 0.975, 3);
CSIF_sm_high = quantile(CSIF_sm_ens, 0.975, 3);
CSIF_tair_high = quantile(CSIF_tair_ens, 0.975, 3);
CSIF_vpd_high = quantile(CSIF_vpd_ens, 0.975, 3);

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(CSIF_obs)) = 0;

%% Map
clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],9);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4;clr(1,:).^10],9);
clr = flipud([clr1(1:8,:);clr2(2:9,:)]);

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 4];

axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, CSIF_obs)
caxis([-0.08 0.08])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
ax = gca;
ax.Position(1) = 0.11;
ax.Position(2) = 0.02;

cb = colorbar('northoutside');
cb.Position = [0.3    0.86    0.4    0.04];
cb.Ticks = -0.08:0.01:0.08;
cb.TickLabels = {'-0.08','','-0.06','','-0.04','','-0.02','','0','','0.02','','0.04','','0.06','','0.08'};
cb.FontSize = 7;
cb.TickLength = 0.06;
xlabel(cb, 'Mean CSIF anomaly (mW m^{-2} nm^{-1} sr^{-1})','FontSize',8)

%% Add bar plots by ecoregion
clr = wesanderson('fantasticfox1');

% Cold deserts
h1 = axes('Parent', gcf, 'Position', [0.07 0.72 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(CSIF_obs(ecoL2==10.1)) nanmean(CSIF_obs(ecoL2==10.1))], 'k-', 'LineWidth',2)
hold on;
bar(1, nanmean(CSIF_all(ecoL2==10.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(ecoL2==10.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(ecoL2==10.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(ecoL2==10.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(ecoL2==10.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(ecoL2==10.1)) nanmean(CSIF_all_high(ecoL2==10.1))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(ecoL2==10.1)) nanmean(CSIF_par_high(ecoL2==10.1))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(ecoL2==10.1)) nanmean(CSIF_sm_high(ecoL2==10.1))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(ecoL2==10.1)) nanmean(CSIF_tair_high(ecoL2==10.1))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(ecoL2==10.1)) nanmean(CSIF_vpd_high(ecoL2==10.1))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Cold Deserts', 'FontSize',7)
annotation('line',[0.22 0.4],[0.83 0.75], 'LineWidth',1);
annotation('line',[0.22 0.43],[0.83 0.51], 'LineWidth',1);

% Mediterranean California
h1 = axes('Parent', gcf, 'Position', [0.07 0.4 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(CSIF_obs(ecoL2==11.1)) nanmean(CSIF_obs(ecoL2==11.1))], 'k-', 'LineWidth',2)
hold on;
bar(1, nanmean(CSIF_all(ecoL2==11.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(ecoL2==11.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(ecoL2==11.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(ecoL2==11.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(ecoL2==11.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(ecoL2==11.1)) nanmean(CSIF_all_high(ecoL2==11.1))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(ecoL2==11.1)) nanmean(CSIF_par_high(ecoL2==11.1))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(ecoL2==11.1)) nanmean(CSIF_sm_high(ecoL2==11.1))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(ecoL2==11.1)) nanmean(CSIF_tair_high(ecoL2==11.1))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(ecoL2==11.1)) nanmean(CSIF_vpd_high(ecoL2==11.1))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7)
ylabel('Mean CSIF anomaly (mW m^{-2} nm^{-1} sr^{-1})', 'FontSize',8)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Mediterranean California', 'FontSize',7)
annotation('line',[0.22 0.34],[0.51 0.39], 'LineWidth',1);

% Warm deserts
h1 = axes('Parent', gcf, 'Position', [0.07 0.08 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(CSIF_obs(ecoL2==10.2)) nanmean(CSIF_obs(ecoL2==10.2))], 'k-', 'LineWidth',2)
hold on;
bar(1, nanmean(CSIF_all(ecoL2==10.2)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(ecoL2==10.2)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(ecoL2==10.2)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(ecoL2==10.2)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(ecoL2==10.2)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(ecoL2==10.2)) nanmean(CSIF_all_high(ecoL2==10.2))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(ecoL2==10.2)) nanmean(CSIF_par_high(ecoL2==10.2))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(ecoL2==10.2)) nanmean(CSIF_sm_high(ecoL2==10.2))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(ecoL2==10.2)) nanmean(CSIF_tair_high(ecoL2==10.2))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(ecoL2==10.2)) nanmean(CSIF_vpd_high(ecoL2==10.2))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Warm Deserts', 'FontSize',7)
annotation('line',[0.22 0.45],[0.16 0.29], 'LineWidth',1);
annotation('line',[0.22 0.68],[0.16 0.12], 'LineWidth',1);

% Semiarid prairies
h1 = axes('Parent', gcf, 'Position', [0.78 0.72 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(CSIF_obs(ecoL2==9.4)) nanmean(CSIF_obs(ecoL2==9.4))], 'k-', 'LineWidth',2)
hold on;
bar(1, nanmean(CSIF_all(ecoL2==9.4)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(ecoL2==9.4)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(ecoL2==9.4)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(ecoL2==9.4)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(ecoL2==9.4)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(ecoL2==9.4)) nanmean(CSIF_all_high(ecoL2==9.4))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(ecoL2==9.4)) nanmean(CSIF_par_high(ecoL2==9.4))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(ecoL2==9.4)) nanmean(CSIF_sm_high(ecoL2==9.4))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(ecoL2==9.4)) nanmean(CSIF_tair_high(ecoL2==9.4))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(ecoL2==9.4)) nanmean(CSIF_vpd_high(ecoL2==9.4))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7,'YAxisLocation','right')
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Semiarid prairies', 'FontSize',7)
annotation('line',[0.78 0.68],[0.78 0.45], 'LineWidth',1);

% Upper Gila Mountains
h1 = axes('Parent', gcf, 'Position', [0.78 0.4 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(CSIF_obs(ecoL2==13.1)) nanmean(CSIF_obs(ecoL2==13.1))], 'k-', 'LineWidth',2)
hold on;
bar(1, nanmean(CSIF_all(ecoL2==13.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(ecoL2==13.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(ecoL2==13.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(ecoL2==13.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(ecoL2==13.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(ecoL2==13.1)) nanmean(CSIF_all_high(ecoL2==13.1))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(ecoL2==13.1)) nanmean(CSIF_par_high(ecoL2==13.1))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(ecoL2==13.1)) nanmean(CSIF_sm_high(ecoL2==13.1))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(ecoL2==13.1)) nanmean(CSIF_tair_high(ecoL2==13.1))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(ecoL2==13.1)) nanmean(CSIF_vpd_high(ecoL2==13.1))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.01 0.002],...
        'YAxisLocation','right','YTickLabels',{'-0.01','','0'})
ylabel('Mean CSIF anomaly (mW m^{-2} nm^{-1} sr^{-1})', 'FontSize',8)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Upper Gila Mountains', 'FontSize',7)
annotation('line',[0.78 0.54],[0.46 0.255], 'LineWidth',1);

% Sierra Madre Piedmont
h1 = axes('Parent', gcf, 'Position', [0.78 0.08 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(CSIF_obs(ecoL2==12.1)) nanmean(CSIF_obs(ecoL2==12.1))], 'k-', 'LineWidth',2)
hold on;
bar(1, nanmean(CSIF_all(ecoL2==12.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(ecoL2==12.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(ecoL2==12.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(ecoL2==12.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(ecoL2==12.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(ecoL2==12.1)) nanmean(CSIF_all_high(ecoL2==12.1))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(ecoL2==12.1)) nanmean(CSIF_par_high(ecoL2==12.1))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(ecoL2==12.1)) nanmean(CSIF_sm_high(ecoL2==12.1))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(ecoL2==12.1)) nanmean(CSIF_tair_high(ecoL2==12.1))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(ecoL2==12.1)) nanmean(CSIF_vpd_high(ecoL2==12.1))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7,'YAxisLocation','right')
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Sierra Madre Piedmont', 'FontSize',7)
annotation('line',[0.78 0.55],[0.24 0.18], 'LineWidth',1);

% Save figure
set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/csif-regional-attribution.png')
print('-dtiff','-f1','-r300','./output/csif-regional-attribution.tif')
close all;

%% Make overall drought figure
h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 4.5 2];

plot([0 6],[nanmean(CSIF_obs(~isnan(ecoL2))) nanmean(CSIF_obs(~isnan(ecoL2)))], 'k-', 'LineWidth',2)
text(5.75, nanmean(CSIF_obs(~isnan(ecoL2))), 'observed','FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','right')
hold on;
bar(1, nanmean(CSIF_all(~isnan(ecoL2))), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(CSIF_par(~isnan(ecoL2))), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(CSIF_sm(~isnan(ecoL2))), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(CSIF_tair(~isnan(ecoL2))), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(CSIF_vpd(~isnan(ecoL2))), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
plot([1 1], [nanmean(CSIF_all_low(~isnan(ecoL2))) nanmean(CSIF_all_high(~isnan(ecoL2)))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [nanmean(CSIF_par_low(~isnan(ecoL2))) nanmean(CSIF_par_high(~isnan(ecoL2)))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [nanmean(CSIF_sm_low(~isnan(ecoL2))) nanmean(CSIF_sm_high(~isnan(ecoL2)))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [nanmean(CSIF_tair_low(~isnan(ecoL2))) nanmean(CSIF_tair_high(~isnan(ecoL2)))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [nanmean(CSIF_vpd_low(~isnan(ecoL2))) nanmean(CSIF_vpd_high(~isnan(ecoL2)))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
ax = gca;
ax.YAxis.Exponent = 0;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],'XTick',1:5,...
        'XLim',[0.25 5.75], 'FontSize',9)
yl = ylabel('Mean CSIF anomaly (mW m^{-2} nm^{-1} sr^{-1})', 'FontSize',7);
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
% ax = gca;
% ax.Position(3) = 0.55;

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/csif-total-regional-attribution.png')
print('-dtiff','-f1','-r300','./output/csif-total-regional-attribution.tif')
close all;


