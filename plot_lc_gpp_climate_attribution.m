% Plot GPP anomaly attribution by land cover type
alphabet = 'abcdefghijklmnopqrstuvwxyz';

%% Read in SMAP grid
load ./output/smap_gridded_anomaly_attribution;
GPP_obs(isnan(GPP_all)) = NaN; % need to compare apples-to-apples
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
load ./data/rangeland.mat;
lc = {'Forest','Shrubland','Savanna','Annual','Perennial','Crop (NW)','Crop (SW)','Crop (plains)'};

%% Add EcoRegions 
load ./data/ecoregions.mat;

%% Exclude water and LC outside ecoregion bounds
rangeland(rangeland==0) = NaN;

%% Add bar plots by land cover
nrows = 3;
ncols = 3;

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 5.5];
ax = tight_subplot(nrows, ncols, [0.05 0.02], [0.08 0.05], [0.1 0.05]);

clr = wesanderson('fantasticfox1');

for i = 1:length(lc)
    
    axes(ax(i))
    
    plot([0 6],[nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2))) nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2)))], 'k-', 'LineWidth',2)
    if i ~= 4 & i ~= 7
        text(5.75, nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2))), 'SMAP L4C','FontSize',8,'VerticalAlignment','bottom', 'HorizontalAlignment','right')
    else
        text(5.75, nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2))), 'SMAP L4C','FontSize',8,'VerticalAlignment','top', 'HorizontalAlignment','right')
    end
    hold on;
    bar(1, nanmean(GPP_all(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
    bar(2, nanmean(GPP_par(rangeland==i & ~isnan(ecoL2))), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
    bar(3, nanmean(GPP_sm(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
    bar(4, nanmean(GPP_tair(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
    bar(5, nanmean(GPP_vpd(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
    plot([1 1], [nanmean(GPP_all_low(rangeland==i & ~isnan(ecoL2))) nanmean(GPP_all_high(rangeland==i & ~isnan(ecoL2)))], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
    plot([2 2], [nanmean(GPP_par_low(rangeland==i & ~isnan(ecoL2))) nanmean(GPP_par_high(rangeland==i & ~isnan(ecoL2)))], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
    plot([3 3], [nanmean(GPP_sm_low(rangeland==i & ~isnan(ecoL2))) nanmean(GPP_sm_high(rangeland==i & ~isnan(ecoL2)))], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
    plot([4 4], [nanmean(GPP_tair_low(rangeland==i & ~isnan(ecoL2))) nanmean(GPP_tair_high(rangeland==i & ~isnan(ecoL2)))], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
    plot([5 5], [nanmean(GPP_vpd_low(rangeland==i & ~isnan(ecoL2))) nanmean(GPP_vpd_high(rangeland==i & ~isnan(ecoL2)))], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
    hold off;
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
            'XLim',[0.25 5.75], 'FontSize',9, 'YLim',[-1 0.4], 'YTick',-1:0.25:0.25)
        
    if i > length(lc)-3
        set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'},'FontSize',9)
        xtickangle(-20)
    else
        set(gca, 'XTickLabel','')
    end
    
    if i==4
        ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',10)
    elseif rem(i, ncols) == 1
        ylabel('', 'FontSize',7)
    else
        set(gca, 'YTickLabel','')
    end
    
    ylim = get(gca,'YLim');
    text(0.5, ylim(2), [alphabet(i),') ',lc{i}], 'FontSize',11, 'FontWeight','bold');
    
end

axes(ax(9))
box off;
set(gca, 'YColor','w', 'XColor','w');

set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/smap-gpp-lc-attribution.png')
print('-dtiff','-f1','-r300','./output/smap-gpp-lc-attribution.tif')
close all;

