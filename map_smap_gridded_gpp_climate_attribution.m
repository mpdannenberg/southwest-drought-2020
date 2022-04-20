% Make maps of anomaly attribution
latlim = [28 49];
lonlim = [-125 -100];
ndays = 31 + 31 + 30 + 31; % Total number of days (for conversion from gC m-2 day-1 to gC m-2)

states = shaperead('usastatehi','UseGeoCoords',true);

clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],7);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4;clr(1,:).^10],7);
clr = flipud([clr1(1:6,:);clr2(2:7,:)]);

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 7];

%% Make multi-panel maps of modeled SM- and VPD-driven GPP anomalies
load ./output/smap_gridded_anomaly_attribution;
load ./data/ecoregions.mat;
eco_bounds(isnan(GPP_obs) | isnan(eco_bounds)) = 0;
GPP_sm(eco_bounds==0) = NaN;
GPP_vpd(eco_bounds==0) = NaN;
lat = double(lat);
lon = double(lon);

% soil moisture-driven anomaly
subplot(2,2,1)
axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, ndays*GPP_sm)
caxis([-75 75])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
text(-0.15,0.82,'a', 'FontSize',12, 'FontWeight','bold')
ax = gca;
subplotsqueeze(ax, 1.2);
ax.Position(1) = 0.05;
ax.Position(2) = 0.57;
title('\DeltaGPP_{SM}', 'FontSize',12)

% VPD-driven anomaly
subplot(2,2,2)
axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, ndays*GPP_vpd)
caxis([-75 75])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
text(-0.15,0.82,'b', 'FontSize',12, 'FontWeight','bold')
ax = gca;
subplotsqueeze(ax, 1.2);
ax.Position(1) = 0.5;
ax.Position(2) = 0.57;
title('\DeltaGPP_{VPD}', 'FontSize',12)

cb = colorbar('southoutside');
cb.Position = [0.1 0.58 0.8 0.02];
cb.Ticks = -75:12.5:75;
cb.TickLength = 0.026;
cb.TickLabels = {'-75','','-50','','-25','','0','','25','','50','','75'};
cb.FontSize = 8;
xlabel(cb, 'GPP anomaly (g C m^{-2})','FontSize',10)

%% Make multi-panel maps of modeled SM- and VPD-driven CSIF anomalies
load ./output/csif_gridded_anomaly_attribution.mat;
CSIF_sm(eco_bounds==0) = NaN;
CSIF_vpd(eco_bounds==0) = NaN;
lat = double(lat);
lon = double(lon);

% soil moisture-driven anomaly
subplot(2,2,3)
axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, CSIF_sm)
caxis([-0.04 0.04])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
text(-0.15,0.82,'c', 'FontSize',12, 'FontWeight','bold')
ax = gca;
subplotsqueeze(ax, 1.2);
ax.Position(1) = 0.05;
ax.Position(2) = 0.05;
title('\DeltaCSIF_{SM}', 'FontSize',12)

% VPD-driven anomaly
subplot(2,2,4)
axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, CSIF_vpd)
caxis([-0.04 0.04])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
text(-0.15,0.82,'d', 'FontSize',12, 'FontWeight','bold')
ax = gca;
subplotsqueeze(ax, 1.2);
ax.Position(1) = 0.5;
ax.Position(2) = 0.05;
title('\DeltaCSIF_{VPD}', 'FontSize',12)

cb = colorbar('southoutside');
cb.Position = [0.1 0.06 0.8 0.02];
cb.TickLabels = '';
cb.Ticks = -0.04:(0.02 / 3):0.04;
cb.TickLength = 0.026;
cb.TickLabels = {'-0.04','','','-0.02','','','0','','','0.02','','','0.04'};
cb.FontSize = 8;
xlabel(cb, 'Mean CSIF anomaly (mW m^{-2} nm^{-1} sr^{-1})','FontSize',10)

% Save figure and table
set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/supplemental-smap-gpp-csif-regional-sm-vpd-attribution.tif')
close all;

