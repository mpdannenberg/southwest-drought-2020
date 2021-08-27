% Get precip, vpd, and temperature anomalies

% Space setup
latlim = [28 49];
lonlim = [-125 -100];

% Filtering setup
windowSize = 4;
b = ones(1,windowSize);
a = 1;

% Get PRISM data
ppt = matfile('D:\Data_Analysis\PRISM\PRISM_PPT');
tmax = matfile('D:\Data_Analysis\PRISM\PRISM_TMAX');
tmin = matfile('D:\Data_Analysis\PRISM\PRISM_TMIN');
vpd = matfile('D:\Data_Analysis\PRISM\PRISM_VPDMAX');

lat = ppt.lat;
lon = ppt.lon;
year = ppt.year;
latidx = find(lat >= min(latlim) & lat <= max(latlim));
lonidx = find(lon >= min(lonlim) & lon <= max(lonlim));
ny = length(latidx);
nx = length(lonidx);
nt = length(year);
nm = 12;

year1d = reshape( repmat(year, nm, 1), nt*nm, []);
month1d = reshape( repmat([1:nm]', 1, nt), nt*nm, []);

PPT = ppt.PPT(latidx, lonidx, :, :);
PPT = permute(PPT, [1 2 4 3]);
PPT = reshape(PPT, ny, nx, nt*nm);
PPT_sum = filter(b, a, PPT, [], 3);
PPT = PPT_sum(:, :, month1d==10);
PPT_anom = PPT(:,:,year==2020) - mean(PPT(:, :, year>=1981 & year<=2010), 3);
PPT_rank = NaN(size(PPT_anom));
for i=1:ny
    for j=1:nx
        PPT_rank(i,j) = sum(PPT(i,j,:) < PPT(i,j,year==2020)) + 1;
    end
end
PPT_rank(isnan(PPT_anom)) = NaN;

T = tmax.Tmax(latidx, lonidx, :, :);
T = permute(T, [1 2 4 3]);
T = reshape(T, ny, nx, nt*nm);
T_sum = filter(b, a, T, [], 3) / windowSize;
T = T_sum(:, :, month1d==10);
T_anom = T(:,:,year==2020) - mean(T(:, :, year>=1981 & year<=2010), 3);
T_rank = NaN(size(T_anom));
for i=1:ny
    for j=1:nx
        T_rank(i,j) = sum(T(i,j,:) > T(i,j,year==2020)) + 1;
    end
end
T_rank(isnan(T_anom)) = NaN;

VPD = vpd.VPDmax(latidx, lonidx, :, :);
VPD = permute(VPD, [1 2 4 3]);
VPD = reshape(VPD, ny, nx, nt*nm);
VPD_sum = filter(b, a, VPD, [], 3) / windowSize;
VPD = VPD_sum(:, :, month1d==10);
VPD_anom = VPD(:,:,year==2020) - mean(VPD(:, :, year>=1981 & year<=2010), 3);
VPD_rank = NaN(size(VPD_anom));
for i=1:ny
    for j=1:nx
        VPD_rank(i,j) = sum(VPD(i,j,:) > VPD(i,j,year==2020)) + 1;
    end
end
VPD_rank(isnan(VPD_anom)) = NaN;

% Make figures
states = shaperead('usastatehi','UseGeoCoords', true);

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 3];

clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],7);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4;clr(1,:).^10],7);
clr = flipud([clr1(1:6,:);clr2(2:7,:)]);
subplot(1,3,1)
ax = axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'on','PLineLocation',5,'MLineLocation',10,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',25.11);
axis off;
axis image;
surfm(lat(latidx), lon(lonidx), PPT_anom);
caxis([-200 200]);
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3], 'LineWidth',0.3)
subplotsqueeze(gca, 1.35)
contourm(lat(latidx), lon(lonidx), PPT_rank, 'LevelList',1, 'LineColor','k', 'LineWidth',1.2)
text(-0.16,0.84,'a', 'FontSize',12, 'FontWeight','bold')
ax = gca;
ax.Position(1) = 0.0473;
ax.Position(2) = 0.02;
cbar = colorbar('southoutside');
cbar.Position(2) = 0.18;
cbar.Position(4) = 0.05;
cbar.Ticks = -200:(200/6):200;
cbar.TickLabels = {'-200','','','-100','','','0','','','100','','','200'};
cbar.TickLength = 0.08;
xlabel(cbar, 'Precipitation anomaly (mm)');

clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],8);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4;clr(1,:).^10],8);
clr = flipud([clr1(1:7,:);clr2(2:8,:)]);
subplot(1,3,2)
ax = axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'on','PLineLocation',5,'MLineLocation',10,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',25.11);
axis off;
axis image;
surfm(lat(latidx), lon(lonidx), T_anom);
caxis([-3.5 3.5]);
colormap(gca, flipud(clr));
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3], 'LineWidth',0.3)
subplotsqueeze(gca, 1.35)
contourm(lat(latidx), lon(lonidx), T_rank, 'LevelList',1, 'LineColor','k', 'LineWidth',1.2)
text(-0.16,0.84,'b', 'FontSize',12, 'FontWeight','bold')
ax = gca;
ax.Position(2) = 0.02;
cbar = colorbar('southoutside');
cbar.Position(2) = 0.18;
cbar.Position(4) = 0.05;
cbar.Ticks = -3.5:0.5:3.5;
cbar.TickLabels = {'','-3','','-2','','-1','','0','','1','','2','','3',''};
cbar.TickLength = 0.08;
xlabel(cbar, 'T_{max} anomaly (K)');

clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],7);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4;clr(1,:).^10],7);
clr = flipud([clr1(1:6,:);clr2(2:7,:)]);
subplot(1,3,3)
ax = axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'on','PLineLocation',5,'MLineLocation',10,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',25.11);
axis off;
axis image;
surfm(lat(latidx), lon(lonidx), VPD_anom);
caxis([-15 15]);
colormap(gca, flipud(clr));
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3], 'LineWidth',0.3)
subplotsqueeze(gca, 1.35)
contourm(lat(latidx), lon(lonidx), VPD_rank, 'LevelList',1, 'LineColor','k', 'LineWidth',1.2)
text(-0.16,0.84,'c', 'FontSize',12, 'FontWeight','bold')
ax = gca;
ax.Position(1) = 0.6989;
ax.Position(2) = 0.02;
cbar = colorbar('southoutside');
cbar.Position(2) = 0.18;
cbar.Position(4) = 0.05;
cbar.Ticks = -15:2.5:15;
cbar.TickLabels = {'-15','','-10','','-5','','0','','5','','10','','15'};
cbar.TickLength = 0.08;
xlabel(cbar, 'VPD_{max} anomaly (hPa)');

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/prism-2020-drought-anomalies.png')
close all;


