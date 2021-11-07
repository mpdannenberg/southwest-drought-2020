% Compare Ameriflux GPP anomalies to SMAP GPP anomalies
GPP_obs = readtable('./output/ameriflux_gpp_attribution.xlsx');
GPP_smap = readtable('./output/ameriflux_smap_attribution.xlsx');
sites = GPP_obs.Site;

clr = wesanderson('fantasticfox1');

y = cell2mat(cellfun(@str2num,GPP_obs.dGPP,'un',0));
yhat = cell2mat(cellfun(@str2num,GPP_smap.dGPP_SMAP,'un',0));

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 4];

b = bar(1:9, [y yhat], 1, 'LineWidth',1.2);
b(1).FaceColor = clr(3,:);
b(2).FaceColor = clr(1,:);
ax = gca;
set(ax, 'XAxisLocation','top', 'TickDir','out', 'TickLength',[0.015 0],...
    'XTickLabel',sites)
box off;
ax.Position(2) = 0.05;
ylabel('July-October GPP anomaly (g C m^{-2})', 'FontSize',12)
lgd = legend('Tower','SMAP', 'Location','south');
legend('boxoff')
lgd.FontSize = 12;
lgd.Position(1) = 0.75;
lgd.Position(2) = 0.5;

set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/ameriflux-smap-gpp-comparison.tif')
close all;
