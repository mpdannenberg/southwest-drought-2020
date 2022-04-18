% Plot total study are GPP attribution with time series of annual GPP

%% Read in SMAP grid
load ./output/smap_gridded_anomaly_attribution;
GPP_obs(isnan(GPP_all)) = NaN; % need to compare apples-to-apples
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Rearrange dimensions
GPP_all_ens = permute(GPP_all_ens, [3 1 2]);
GPP_par_ens = permute(GPP_par_ens, [3 1 2]);
GPP_sm_ens = permute(GPP_sm_ens, [3 1 2]);
GPP_tair_ens = permute(GPP_tair_ens, [3 1 2]);
GPP_vpd_ens = permute(GPP_vpd_ens, [3 1 2]);

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(GPP_obs)) = 0;
ecoL2(isnan(GPP_obs)) = NaN;

%% Make overall drought figure
h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 4.5 3.5];
clr = wesanderson('fantasticfox1');

% Annual GPP
load ./data/SMAP_L4C_GPP_monthly;
windowSize = 4;
b = ones(1,windowSize)/windowSize;
a = 1;
gpp = filter(b, a, GPP_monthly, [], 3);
clear b a windowSize;

a = 9000 * 9000 * (31 + 31 + 30 + 31) * (1 / 10^12);
gpp = a * gpp(:,:,mo==10);
for i=1:6; gpp_temp = gpp(:,:,i); GPP_total(i) = nansum(gpp_temp(~isnan(ecoL2))); end

subplot(3,1,1)
plot(2015:2020, GPP_total, 'k-', 'LineWidth',1.2)
hold on;
plot([2015 2020], [mean(GPP_total(1:5)) mean(GPP_total(1:5))], 'k--')
plot(2019:2020, GPP_total(5:6),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
scatter(2015:2020, GPP_total, 30, 'k', 'filled')
scatter(2020, GPP_total(6), 40, clr(2,:).^2, 'filled')
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0])
yl = ylabel('Jul-Oct GPP (Tg C)', 'FontSize',9);
yl.Position(1) = yl.Position(1)-0.05;
ylim = get(gca,'YLim');
text(2015.1, ylim(2), 'a', 'FontSize',12, 'FontWeight','bold','VerticalAlignment','bottom')
text(2020.1, GPP_total(6), [num2str(100*round(GPP_total(6)/mean(GPP_total(1:5)), 2)),'%'],...
    'HorizontalAlignment','left', 'VerticalAlignment','bottom',...
    'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',12)

% Attribution
subplot(3,1,[2 3])
plot([0 6],[nansum(a*GPP_obs(~isnan(ecoL2))) nansum(a*GPP_obs(~isnan(ecoL2)))], 'k-', 'LineWidth',2)
text(3, nansum(a*GPP_obs(~isnan(ecoL2))), 'SMAP L4C total anomaly','FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment','center')
hold on;
bar(1, nansum(a*GPP_all(~isnan(ecoL2))), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nansum(a*GPP_par(~isnan(ecoL2))), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nansum(a*GPP_sm(~isnan(ecoL2))), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nansum(a*GPP_tair(~isnan(ecoL2))), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nansum(a*GPP_vpd(~isnan(ecoL2))), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nansum(a*GPP_all_ens(:, ~isnan(ecoL2)), 2), [0.025 0.975]);
GPP_par_ci = quantile(nansum(a*GPP_par_ens(:, ~isnan(ecoL2)), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nansum(a*GPP_sm_ens(:, ~isnan(ecoL2)), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nansum(a*GPP_tair_ens(:, ~isnan(ecoL2)), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nansum(a*GPP_vpd_ens(:, ~isnan(ecoL2)), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],'XTick',1:5,...
        'XLim',[0.25 5.75], 'FontSize',9, 'YLim',[-150 25],'YTick',-150:25:25)
ylim = get(gca, 'YLim');
ylabel('Jul-Oct GPP anomaly (Tg C)', 'FontSize',9)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
text(0.35, ylim(2), 'b', 'FontSize',12, 'FontWeight','bold','VerticalAlignment','top')

h1 = axes('Parent', gcf, 'Position', [0.77 0.09 0.18 0.3]);
set(h1, 'Color','w')
p = pie(-1*fliplr([nansum(a*GPP_par(~isnan(ecoL2))) nansum(a*GPP_sm(~isnan(ecoL2))) nansum(a*GPP_tair(~isnan(ecoL2))) nansum(a*GPP_vpd(~isnan(ecoL2)))]), zeros(1,4));
colormap(gca, flipud([sqrt(clr(4,:)); clr(3,:); clr(1,:); clr(2,:)]))
set(findobj(p,'Type','text'), 'FontSize',7);

set(gcf,'PaperPositionMode','auto')
% print('-dpng','-f1','-r300','./output/smap-gpp-total-regional-attribution.png')
print('-dtiff','-f1','-r300','./output/smap-gpp-total-regional-attribution.tif')
close all;


