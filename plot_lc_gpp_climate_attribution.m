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
GPP_all_ens = permute(GPP_all_ens, [3 1 2]);
GPP_par_ens = permute(GPP_par_ens, [3 1 2]);
GPP_sm_ens = permute(GPP_sm_ens, [3 1 2]);
GPP_tair_ens = permute(GPP_tair_ens, [3 1 2]);
GPP_vpd_ens = permute(GPP_vpd_ens, [3 1 2]);

%% Read in land cover data
load ./data/rangeland.mat;
rangeland(rangeland == 6) = NaN; % No northwestern croplands
rangeland(rangeland == 7) = 6; % Reclassify remaining croplands
rangeland(rangeland == 8) = 7;
lc = {'Forest','Shrubland','Savanna','Annual','Perennial','Crop (SW)','Crop (plains)'};

%% Add EcoRegions 
load ./data/ecoregions.mat;

%% Exclude water and LC outside ecoregion bounds
rangeland(rangeland==0 | isnan(eco_bounds) | eco_bounds == 0) = NaN;

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
    if i ~= 4 & i ~= 6
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
    GPP_all_ci = quantile(nanmean(GPP_all_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_par_ci = quantile(nanmean(GPP_par_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
    plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
    plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
    plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
    plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
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

axes(ax(8))
box off;
set(gca, 'YColor','w', 'XColor','w', 'Color','none');

axes(ax(9))
box off;
set(gca, 'YColor','w', 'XColor','w', 'Color','none');

set(gcf,'PaperPositionMode','auto')
% print('-dpng','-f1','-r300','./output/smap-gpp-lc-attribution.png')
print('-dtiff','-f1','-r300','./output/smap-gpp-lc-attribution.tif')
close all;

