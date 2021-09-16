% Show anomalies by ecoregion

%% Read in SMAP grid
load ./data/SMAP_L4C_GPP_monthly;
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(eco_bounds)) = 0;

%% Calculate annual July-October mean GPP
windowSize = 4;
b = ones(1,windowSize)/windowSize;
a = 1;
gpp = filter(b, a, GPP_monthly, [], 3);
clear b a windowSize;

% a = 9000 * 9000 * (31 + 31 + 30 + 31) * (1 / 10^12);
gpp = gpp(:,:,mo==10);
mgpp = mean(gpp(:,:,1:5), 3); mgpp(eco_bounds==0) = NaN;


%% Map
clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],13);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4],5);
clr = flipud([clr1(1:12,:);clr2(2:5,:)]);

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
surfm(lat, lon, mgpp)
caxis([0 8])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
ax = gca;
ax.Position(1) = 0.11;
ax.Position(2) = 0.02;

cb = colorbar('northoutside');
cb.Position = [0.3    0.86    0.4    0.04];
cb.Ticks = 0:0.5:8;
cb.TickLabels = {'0','','1','','2','','3','','4','','5','','6','','7','','8'};
cb.FontSize = 7;
cb.TickLength = 0.06;
xlabel(cb, 'Mean July-October GPP (g C m^{-2} day^{-1})','FontSize',8)

%% Add plots by ecoregion
clr = wesanderson('fantasticfox1');

% Cold deserts
h1 = axes('Parent', gcf, 'Position', [0.07 0.72 0.15 0.19]);
set(h1, 'Color','w')
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(ecoL2==10.1)); end
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[2015 2020], 'FontSize',7)
ylim = get(gca, 'YLim');
text(2015.1, min(ylim), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)
title('Cold Deserts', 'FontSize',7)
annotation('line',[0.22 0.4],[0.8 0.75], 'LineWidth',1);
annotation('line',[0.22 0.43],[0.8 0.51], 'LineWidth',1);

% Mediterranean California
h1 = axes('Parent', gcf, 'Position', [0.07 0.4 0.15 0.19]);
set(h1, 'Color','w')
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(ecoL2==11.1)); end
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[2015 2020], 'FontSize',7)
ylim = get(gca, 'YLim');
text(2015.1, min(ylim), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)
title('Mediterranean California', 'FontSize',7)
annotation('line',[0.22 0.34],[0.48 0.39], 'LineWidth',1);
ylabel('Jul-Oct GPP (g C m^{-2} day^{-1})', 'FontSize',10)

% Warm deserts
h1 = axes('Parent', gcf, 'Position', [0.07 0.08 0.15 0.19]);
set(h1, 'Color','w')
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(ecoL2==10.2)); end
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[2015 2020], 'FontSize',7)
ylim = get(gca, 'YLim');
text(2015.1, min(ylim), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)
title('Warm Deserts', 'FontSize',7)
annotation('line',[0.22 0.45],[0.16 0.29], 'LineWidth',1);
annotation('line',[0.22 0.68],[0.16 0.12], 'LineWidth',1);

% Semiarid prairies
h1 = axes('Parent', gcf, 'Position', [0.78 0.72 0.15 0.19]);
set(h1, 'Color','w')
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(ecoL2==9.4)); end
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[2015 2020], 'FontSize',7, 'YAxisLocation','right')
ylim = get(gca, 'YLim');
text(2015.1, min(ylim), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)
title('Semiarid prairies', 'FontSize',7)
annotation('line',[0.78 0.68],[0.78 0.45], 'LineWidth',1);

% Upper Gila Mountains
h1 = axes('Parent', gcf, 'Position', [0.78 0.4 0.15 0.19]);
set(h1, 'Color','w')
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(ecoL2==13.1)); end
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[2015 2020], 'FontSize',7, 'YAxisLocation','right')
ylim = get(gca, 'YLim');
text(2015.1, min(ylim), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)
title('Upper Gila Mountains', 'FontSize',7)
annotation('line',[0.78 0.54],[0.46 0.255], 'LineWidth',1);
ylabel('Jul-Oct GPP (g C m^{-2} day^{-1})', 'FontSize',10)

% Sierra Madre Piedmont
h1 = axes('Parent', gcf, 'Position', [0.78 0.08 0.15 0.19]);
set(h1, 'Color','w')
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(ecoL2==12.1)); end
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[2015 2020], 'FontSize',7, 'YAxisLocation','right')
ylim = get(gca, 'YLim');
text(2015.1, min(ylim), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)
title('Sierra Madre Piedmont', 'FontSize',7)
annotation('line',[0.78 0.55],[0.24 0.18], 'LineWidth',1);

% Save figure
set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/smap-gpp-regional-mean.tif')
close all;

