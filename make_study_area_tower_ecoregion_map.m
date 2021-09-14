% Make map of study area, ecoregions, and flux towers

%% Read in SMAP grid
load ./output/smap_gridded_anomaly_attribution;
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Read in land cover data
load ./data/rangeland.mat;
lc = {'Forest','Shrubland','Savanna','Annual','Perennial','Crop (NW)','Crop (SW)','Crop (plains)'};

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
clear ecoL2_code;

%% Get boundaries of ecoregions
eco_bounds = zeros(size(ecoL2));
for i = 1:length(ecos)
    
    eco_bounds(ecoL2==ecos(i)) = i;
    
end
eco_bounds(isnan(GPP_obs)) = 0;

%% Save ecoregion boundaries
save('./data/ecoregions.mat', 'eco_bounds','ecoL2','ecos','ecoL3','lat','lon');

%% Exclude water and LC outside ecoregion bounds
rangeland(rangeland==0) = NaN;
rangeland(isnan(eco_bounds) | eco_bounds==0) = NaN;

%% make map with ecoregions and flux towers... need to work on this more
h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 6];

clr = wesanderson('fantasticfox1');
clr2 = [clr(3,:).^3
    clr(1,:).^3
    clr(3,:)
    clr(5,:)
    clr(1,:)
    clr(4,:)
    sqrt(clr(2,:))
    clr(2,:).^2];

eco_bounds(eco_bounds==0) = NaN;
axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'on','PLineLocation',4,'MLineLocation',8,'MeridianLabel','on',...
        'ParallelLabel','on','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, rangeland)
caxis([0.5 8.5])
colormap(gca, clr2);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
eco_bounds(isnan(eco_bounds)) = 0;
contourm(lat, lon, eco_bounds, 'LineColor','k', 'LineWidth',1.2, 'LevelList',0.5:1:6.5, 'Fill','off');
ax = gca;
ax.Position(1) = 0.08;
ax.Position(2) = 0.08;

cb = colorbar('southoutside');
cb.Position = [0.03    0.04    0.85    0.03];
cb.TickLabels = lc;
cb.FontSize = 8;
cb.TickLength = 0;

% bounding box
plotm([31 39], [-122 -122], 'k-', 'LineWidth',2)
plotm([31 39], [-102.5 -102.5], 'k-', 'LineWidth',2)
plotm(repmat(31, 1, length(-122:0.1:-102.5)), -122:0.1:-102.5, 'k-', 'LineWidth',2)
plotm(repmat(39, 1, length(-122:0.1:-102.5)), -122:0.1:-102.5, 'k-', 'LineWidth',2)

% Add labels for ecoregions
text(-0.0657, 0.7893, 'a', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(-0.0446, 0.6927, 'a', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(0.0324, 0.6741, 'a', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(-0.0959, 0.6349, 'b', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(0.1128, 0.5619, 'c', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(-0.0102, 0.5878, 'c', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(0.1352, 0.629, 'd', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(0.0292, 0.5947, 'e', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)
text(0.0338, 0.5649, 'f', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',16)

% Inset with tower locations (plus slight offsets for nearby towers to make
% them visibly distinct)
h1 = axes('Parent', gcf, 'Position', [0.48 0.715 0.5 0.29]);
set(h1, 'Color','w')
axesm('lambert','MapLatLimit',[31 39],'MapLonLimit',[-122 -102.5],'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','on','FFaceColor',...
        'w', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1.5, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
axis off;
axis image;
flat = [34.4385     (31.8214 + 0.05)    (31.789379 - 0.05)   (34.3349 - 0.05)   (34.3623 + 0.1)    (31.7438 + 0.05)    34.4255     (31.7365 - 0.05)     38.4309];
flon = [-106.2377   (-110.8661 - 0.05)  (-110.827675 + 0.05) (-106.7442 - 0.05) (-106.702 + 0.05)  (-110.0522 - 0.05)  -105.8615   (-109.9419 + 0.05)   -120.966];
figbp = [1 1 5 2 5 2 3 5 1];
scatterm(flat, flon, 40, figbp, 'filled', 'Marker','^', 'MarkerEdgeColor','k')
caxis(gca, [0.5 8.5])
colormap(gca, clr2);
textm(34.55+0.05, -106.2377, 'Mpj', 'HorizontalAlignment','center',...
    'VerticalAlignment','bottom', 'FontSize',9);
textm((31.8214 + 0.05), (-110.8661 - 0.05), 'SRM', 'HorizontalAlignment','right',...
    'VerticalAlignment','bottom', 'FontSize',9);
textm((31.789379 - 0.05), (-110.827675 + 0.05), 'SRG', 'HorizontalAlignment','right',...
    'VerticalAlignment','top', 'FontSize',9);
textm((34.3349 - 0.05), (-106.7442 - 0.05), 'Ses', 'HorizontalAlignment','center',...
    'VerticalAlignment','top', 'FontSize',9);
textm((34.3623 + 0.3), (-106.85), 'Seg', 'HorizontalAlignment','right',...
    'VerticalAlignment','middle', 'FontSize',9);
textm((31.7438 + 0.05), (-110.0522 - 0.05), 'Whs', 'HorizontalAlignment','left',...
    'VerticalAlignment','bottom', 'FontSize',9);
textm((34.4255 + 0.05), (-105.8615 + 0.05), 'Wjs', 'HorizontalAlignment','left',...
    'VerticalAlignment','top', 'FontSize',9);
textm((31.7365 - 0.05), (-109.9419 + 0.05), 'Wkg', 'HorizontalAlignment','left',...
    'VerticalAlignment','top', 'FontSize',9);
textm((38.4309 + 0.15), (-120.966 + 0.25), 'Ton', 'HorizontalAlignment','left',...
    'VerticalAlignment','middle', 'FontSize',9);

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/study-area-lc-towers.png')
print('-dtiff','-f1','-r300','./output/study-area-lc-towers.tif')
close all;

