% Make map of model R^2
load ./output/smap_gridded_anomaly_attribution;
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Make map of model R^2
clr = wesanderson('fantasticfox1');
clr = flipud(make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],8));

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 4 3.5];

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
ax = gca;
ax.Position(1) = 0.1;
ax.Position(2) = 0.18;

% Add colorbar
cb = colorbar('southoutside');
cb.Position = [0.07 0.12 0.8 0.03];
cb.Ticks = 0:0.1:0.8;
cb.TickLength = 0.035;
xlabel(cb, 'Mean validation-period R^{2}')

h1 = axes('Parent', gcf, 'Position', [0.82 0.8 0.16 0.17]);
set(h1, 'Color','w')
hg = histogram(reshape(GPP_r2,[],1), 0:0.1:0.8,...
    'Normalization','probability', 'FaceColor',clr(5,:),'FaceAlpha',1);
box off;
set(gca, 'FontSize',8,'YColor','w')
xlabel('R^{2}','FontSize',8)

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/gpp-smap-regional-r2-map.png')
close all;
