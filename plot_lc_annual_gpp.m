% Line plots by LC type
load ./output/smap_gridded_anomaly_attribution;
latlim = [28 49];
lonlim = [-125 -100];
alphabet = 'abcdefghijklmnopqrstuvwxyz';
nrows = 7;
ncols = 1;
ndays = 31 + 31 + 30 + 31; % Total number of days (for conversion from gC m-2 day-1 to gC m-2)

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(GPP_obs) | isnan(eco_bounds)) = 0;
GPP_obs(eco_bounds==0) = NaN;

%% Read in land cover data
load ./data/rangeland.mat;
rangeland(rangeland == 6) = NaN; % No northwestern croplands
rangeland(rangeland == 7) = 6; % Reclassify remaining croplands
rangeland(rangeland == 8) = 7;
lc = {'Forest','Shrubland','Savanna','Annual','Perennial','Crop (Central Valley)','Crop (Great Plains)'};

% Exclude water and LC outside ecoregion bounds
rangeland(rangeland==0 | isnan(eco_bounds) | eco_bounds == 0) = NaN;

%% Calculate annual July-October mean GPP
load ./data/SMAP_L4C_GPP_monthly;
windowSize = 4;
b = ones(1,windowSize)/windowSize;
a = 1;
gpp = filter(b, a, GPP_monthly, [], 3);
clear b a windowSize;

gpp = ndays*gpp(:,:,mo==10);

%% Make figure
h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 3. 6];
ax = tight_subplot(nrows, ncols, [0.04 0.04], [0.08 0.08], [0.17 0.15]);

clr = wesanderson('fantasticfox1');

for j = 1:length(lc)
    axes(ax(j))
    for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nanmean(gpp_temp(rangeland==j & ~isnan(ecoL2))); end
    plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
    hold on;
    plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
    plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
    scatter(2015:2020, GPP_total, 30, 'k', 'filled')
    scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
    box off;
    if j>(ncols*(nrows-1))
        set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
                'XLim',[2015 2020], 'FontSize',7)
    else
        set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
                    'XLim',[2015 2020], 'FontSize',7, 'XTickLabel','')
    end
    ylim = get(gca, 'YLim');
    text(2020.2, GPP_total(6), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
        'HorizontalAlignment','left', 'VerticalAlignment','middle',...
        'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',10)
    %title('Cold Deserts', 'FontSize',7)
    if j ~= 6
        text(2015.1,ylim(1)+0.05*diff(ylim),[alphabet(j),') ', lc{j}], 'FontSize',10, 'VerticalAlignment','bottom')
    else
        text(2015.1,ylim(2),[alphabet(j),') ', lc{j}], 'FontSize',10, 'VerticalAlignment','top')
    end
    if j == ceil(nrows/2)
        yl = ylabel('Jul-Oct GPP (g C m^{-2})', 'FontSize',10);
        yl.Position(1) = 2014.2;
    end
end

set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/smap-gpp-lc-annual-plots.tif')
close all;
