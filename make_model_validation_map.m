% Make map of model R^2
load ./output/smap_gridded_anomaly_attribution;
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(GPP_obs) | isnan(eco_bounds)) = 0;
GPP_r2(eco_bounds==0) = NaN;

%% Make map of model R^2
clr = wesanderson('fantasticfox1');
clr = flipud(make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],8));

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 4.5 3.5];

axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'on','PLineLocation',4,'MLineLocation',8,'MeridianLabel','on',...
        'ParallelLabel','on','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, GPP_r2)
caxis([0 0.8])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
ax = gca;
ax.Position = [0.06 0.1800 0.7750 0.8150];

% Add colorbar
cb = colorbar('southoutside');
cb.Position = [0.07 0.12 0.71 0.03];
cb.Ticks = 0:0.1:0.8;
cb.TickLength = 0.035;
xlabel(cb, 'Mean validation-period R^{2}')

h1 = axes('Parent', gcf, 'Position', [0.8 0.65 0.18 0.33]);
set(h1, 'Color','w')
y = reshape(GPP_r2,[],1);
g = reshape(ecoL2,[],1);
boxplot(y, g, 'PlotStyle','compact', 'OutlierSize',2, 'labels',{'Semiarid Prairies','Cold Desert','Warm Desert','Mediterranean CA','Sierra Madre Piedmont','Upper Gila Mtns.'})
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(a,'tag');   % List the names of all the objects 
set(a(25:30), 'Color', clr(5,:)); % Set the box color to green
set(a(31:36), 'Color', 'k');   % Set the whisker color to black
set(a(7:12), 'MarkerEdgeColor', 'k');   % Set the whisker color to black
set(a(19:24), 'MarkerEdgeColor', 'k', 'MarkerSize',5);   % Set the whisker color to black
% hg = histogram(, 0:0.1:0.8,...
%     'Normalization','probability', 'FaceColor',clr(5,:),'FaceAlpha',1);
box off;
set(gca, 'FontSize',8, 'YColor','k', 'TickDir','out', 'TickLength',[0.03 0],...
    'XTickLabels',{'Semiarid Prairies','Cold Desert','Warm Desert','Mediterranean CA','Sierra Madre Piedmont','Upper Gila Mtns.'})
h = findobj(gca, 'type', 'text');
set(h, 'FontSize', 8, 'HorizontalAlignment','right');
h(1).Position(2) = -1;
h(2).Position(2) = -1;
h(3).Position(2) = -1;
h(4).Position(2) = -1;
h(5).Position(2) = -1;
h(6).Position(2) = -1;
text(-2.5,0.45,'R^{2}', 'FontSize',8)

set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/gpp-smap-regional-r2-map.tif')
close all;
