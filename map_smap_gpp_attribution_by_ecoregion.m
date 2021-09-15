% Show anomalies by ecoregion

%% Read in SMAP grid
load ./output/smap_gridded_anomaly_attribution;
GPP_obs(isnan(GPP_all)) = NaN; % need to compare apples-to-apples
latlim = [28 49];
lonlim = [-125 -100];

lat = double(lat);
lon = double(lon);

states = shaperead('usastatehi','UseGeoCoords',true);

%% Calculate CIs for each pixel
GPP_all_ens = permute(GPP_all_ens, [3 1 2]);
GPP_par_ens = permute(GPP_par_ens, [3 1 2]);
GPP_sm_ens = permute(GPP_sm_ens, [3 1 2]);
GPP_tair_ens = permute(GPP_tair_ens, [3 1 2]);
GPP_vpd_ens = permute(GPP_vpd_ens, [3 1 2]);

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(GPP_obs) | isnan(eco_bounds)) = 0;

%% Initiate table
T = table('Size',[6 7], 'VariableTypes',{'string','string','string','string','string','string','string'},...
    'VariableNames',{'Ecoregion','dGPP_SMAP','dGPP_All','dGPP_PAR','dGPP_SM','dGPP_Tair','dGPP_VPD'});
T.Ecoregion = {'Cold Deserts','Warm Deserts','Mediterranean California','Semiarid Prairies','Upper Gila Mountains','Sierra Madre Piedmont'}';

%% Map
clr = wesanderson('fantasticfox1');
clr1 = make_cmap([clr(3,:).^10;clr(3,:).^4;clr(3,:);1 1 1],11);
clr2 = make_cmap([1 1 1;clr(1,:);clr(1,:).^4;clr(1,:).^10],11);
clr = flipud([clr1(1:10,:);clr2(2:11,:)]);

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 4];

axesm('lambert','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid',...
        'off','PLineLocation',4,'MLineLocation',8,'MeridianLabel','off',...
        'ParallelLabel','off','GLineWidth',0.5,'Frame','off','FFaceColor',...
        'none', 'FontName', 'Helvetica','GColor',[0.6 0.6 0.6],...
        'FLineWidth',1, 'FontColor',[0.5 0.5 0.5], 'MLabelParallel',min(latlim)+0.11,...
        'FontSize',8);
axis off;
axis image;
surfm(lat, lon, GPP_obs)
caxis([-1 1])
colormap(gca, clr);
geoshow(states,'FaceColor','none','EdgeColor',[0.3 0.3 0.3])
contourm(lat, lon, eco_bounds, 'LineColor',[0.2 0.2 0.2], 'LineWidth',1.2, 'LevelList',0.5:1:6.5);
ax = gca;
ax.Position(1) = 0.11;
ax.Position(2) = 0.02;

cb = colorbar('northoutside');
cb.Position = [0.3    0.86    0.4    0.04];
cb.Ticks = -1:0.1:1;
cb.TickLabels = {'-1','','-0.8','','-0.6','','-0.4','','-0.2','','0','','0.2','','0.4','','0.6','','0.8','','1'};
cb.FontSize = 7;
cb.TickLength = 0.06;
xlabel(cb, 'Mean GPP anomaly (g C m^{-2} day^{-1})','FontSize',8)

%% Add bar plots by ecoregion
clr = wesanderson('fantasticfox1');

% Cold deserts
h1 = axes('Parent', gcf, 'Position', [0.07 0.72 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(GPP_obs(ecoL2==10.1)) nanmean(GPP_obs(ecoL2==10.1))], 'k-', 'LineWidth',2)
text(3, nanmean(GPP_obs(ecoL2==10.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, nanmean(GPP_all(ecoL2==10.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(GPP_par(ecoL2==10.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(GPP_sm(ecoL2==10.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(GPP_tair(ecoL2==10.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(GPP_vpd(ecoL2==10.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nanmean(GPP_all_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(nanmean(GPP_par_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.85 0.15])
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Cold Deserts', 'FontSize',7)
annotation('line',[0.22 0.4],[0.8 0.75], 'LineWidth',1);
annotation('line',[0.22 0.43],[0.8 0.51], 'LineWidth',1);

T.dGPP_SMAP(1) = num2str(round(nanmean(GPP_obs(ecoL2==10.1)), 2));
T.dGPP_All(1) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_all(ecoL2==10.1)), GPP_all_ci(1), GPP_all_ci(2)); 
T.dGPP_PAR(1) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_par(ecoL2==10.1)), GPP_par_ci(1), GPP_par_ci(2)); 
T.dGPP_SM(1) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_sm(ecoL2==10.1)), GPP_sm_ci(1), GPP_sm_ci(2)); 
T.dGPP_Tair(1) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_tair(ecoL2==10.1)), GPP_tair_ci(1), GPP_tair_ci(2)); 
T.dGPP_VPD(1) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_vpd(ecoL2==10.1)), GPP_vpd_ci(1), GPP_vpd_ci(2)); 

% Mediterranean California
h1 = axes('Parent', gcf, 'Position', [0.07 0.4 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(GPP_obs(ecoL2==11.1)) nanmean(GPP_obs(ecoL2==11.1))], 'k-', 'LineWidth',2)
text(3, nanmean(GPP_obs(ecoL2==11.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, nanmean(GPP_all(ecoL2==11.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(GPP_par(ecoL2==11.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(GPP_sm(ecoL2==11.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(GPP_tair(ecoL2==11.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(GPP_vpd(ecoL2==11.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nanmean(GPP_all_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(nanmean(GPP_par_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.85 0.15])
ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',8)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Mediterranean California', 'FontSize',7)
annotation('line',[0.22 0.34],[0.48 0.39], 'LineWidth',1);

T.dGPP_SMAP(3) = num2str(round(nanmean(GPP_obs(ecoL2==11.1)), 2));
T.dGPP_All(3) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_all(ecoL2==11.1)), GPP_all_ci(1), GPP_all_ci(2)); 
T.dGPP_PAR(3) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_par(ecoL2==11.1)), GPP_par_ci(1), GPP_par_ci(2)); 
T.dGPP_SM(3) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_sm(ecoL2==11.1)), GPP_sm_ci(1), GPP_sm_ci(2)); 
T.dGPP_Tair(3) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_tair(ecoL2==11.1)), GPP_tair_ci(1), GPP_tair_ci(2)); 
T.dGPP_VPD(3) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_vpd(ecoL2==11.1)), GPP_vpd_ci(1), GPP_vpd_ci(2)); 

% Warm deserts
h1 = axes('Parent', gcf, 'Position', [0.07 0.08 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(GPP_obs(ecoL2==10.2)) nanmean(GPP_obs(ecoL2==10.2))], 'k-', 'LineWidth',2)
text(3, nanmean(GPP_obs(ecoL2==10.2)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, nanmean(GPP_all(ecoL2==10.2)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(GPP_par(ecoL2==10.2)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(GPP_sm(ecoL2==10.2)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(GPP_tair(ecoL2==10.2)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(GPP_vpd(ecoL2==10.2)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nanmean(GPP_all_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_par_ci = quantile(nanmean(GPP_par_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.85 0.15])
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Warm Deserts', 'FontSize',7)
annotation('line',[0.22 0.45],[0.16 0.29], 'LineWidth',1);
annotation('line',[0.22 0.68],[0.16 0.12], 'LineWidth',1);

T.dGPP_SMAP(2) = num2str(round(nanmean(GPP_obs(ecoL2==10.2)), 2));
T.dGPP_All(2) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_all(ecoL2==10.2)), GPP_all_ci(1), GPP_all_ci(2)); 
T.dGPP_PAR(2) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_par(ecoL2==10.2)), GPP_par_ci(1), GPP_par_ci(2)); 
T.dGPP_SM(2) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_sm(ecoL2==10.2)), GPP_sm_ci(1), GPP_sm_ci(2)); 
T.dGPP_Tair(2) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_tair(ecoL2==10.2)), GPP_tair_ci(1), GPP_tair_ci(2)); 
T.dGPP_VPD(2) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_vpd(ecoL2==10.2)), GPP_vpd_ci(1), GPP_vpd_ci(2)); 

% Semiarid prairies
h1 = axes('Parent', gcf, 'Position', [0.78 0.72 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(GPP_obs(ecoL2==9.4)) nanmean(GPP_obs(ecoL2==9.4))], 'k-', 'LineWidth',2)
text(3, nanmean(GPP_obs(ecoL2==9.4)), 'SMAP L4C','FontSize',7,'VerticalAlignment','bottom','HorizontalAlignment','center')
hold on;
bar(1, nanmean(GPP_all(ecoL2==9.4)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(GPP_par(ecoL2==9.4)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(GPP_sm(ecoL2==9.4)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(GPP_tair(ecoL2==9.4)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(GPP_vpd(ecoL2==9.4)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nanmean(GPP_all_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_par_ci = quantile(nanmean(GPP_par_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.85 0.15],'YAxisLocation','right')
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Semiarid prairies', 'FontSize',7)
annotation('line',[0.78 0.68],[0.78 0.45], 'LineWidth',1);

T.dGPP_SMAP(4) = num2str(round(nanmean(GPP_obs(ecoL2==9.4)), 2));
T.dGPP_All(4) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_all(ecoL2==9.4)), GPP_all_ci(1), GPP_all_ci(2)); 
T.dGPP_PAR(4) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_par(ecoL2==9.4)), GPP_par_ci(1), GPP_par_ci(2)); 
T.dGPP_SM(4) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_sm(ecoL2==9.4)), GPP_sm_ci(1), GPP_sm_ci(2)); 
T.dGPP_Tair(4) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_tair(ecoL2==9.4)), GPP_tair_ci(1), GPP_tair_ci(2)); 
T.dGPP_VPD(4) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_vpd(ecoL2==9.4)), GPP_vpd_ci(1), GPP_vpd_ci(2)); 

% Upper Gila Mountains
h1 = axes('Parent', gcf, 'Position', [0.78 0.4 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(GPP_obs(ecoL2==13.1)) nanmean(GPP_obs(ecoL2==13.1))], 'k-', 'LineWidth',2)
text(3, nanmean(GPP_obs(ecoL2==13.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, nanmean(GPP_all(ecoL2==13.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(GPP_par(ecoL2==13.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(GPP_sm(ecoL2==13.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(GPP_tair(ecoL2==13.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(GPP_vpd(ecoL2==13.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nanmean(GPP_all_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(nanmean(GPP_par_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.85 0.15],'YAxisLocation','right')
ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',8)
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Upper Gila Mountains', 'FontSize',7)
annotation('line',[0.78 0.54],[0.46 0.255], 'LineWidth',1);

T.dGPP_SMAP(5) = num2str(round(nanmean(GPP_obs(ecoL2==13.1)), 2));
T.dGPP_All(5) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_all(ecoL2==13.1)), GPP_all_ci(1), GPP_all_ci(2)); 
T.dGPP_PAR(5) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_par(ecoL2==13.1)), GPP_par_ci(1), GPP_par_ci(2)); 
T.dGPP_SM(5) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_sm(ecoL2==13.1)), GPP_sm_ci(1), GPP_sm_ci(2)); 
T.dGPP_Tair(5) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_tair(ecoL2==13.1)), GPP_tair_ci(1), GPP_tair_ci(2)); 
T.dGPP_VPD(5) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_vpd(ecoL2==13.1)), GPP_vpd_ci(1), GPP_vpd_ci(2)); 

% Sierra Madre Piedmont
h1 = axes('Parent', gcf, 'Position', [0.78 0.08 0.15 0.19]);
set(h1, 'Color','w')
plot([0 6],[nanmean(GPP_obs(ecoL2==12.1)) nanmean(GPP_obs(ecoL2==12.1))], 'k-', 'LineWidth',2)
text(3, nanmean(GPP_obs(ecoL2==12.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','bottom','HorizontalAlignment','center')
hold on;
bar(1, nanmean(GPP_all(ecoL2==12.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, nanmean(GPP_par(ecoL2==12.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, nanmean(GPP_sm(ecoL2==12.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, nanmean(GPP_tair(ecoL2==12.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, nanmean(GPP_vpd(ecoL2==12.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(nanmean(GPP_all_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(nanmean(GPP_par_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(nanmean(GPP_sm_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(nanmean(GPP_tair_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(nanmean(GPP_vpd_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',7, 'YLim',[-0.85 0.15],'YAxisLocation','right')
set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-25)
title('Sierra Madre Piedmont', 'FontSize',7)
annotation('line',[0.78 0.55],[0.24 0.18], 'LineWidth',1);

T.dGPP_SMAP(6) = num2str(round(nanmean(GPP_obs(ecoL2==12.1)), 2));
T.dGPP_All(6) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_all(ecoL2==12.1)), GPP_all_ci(1), GPP_all_ci(2)); 
T.dGPP_PAR(6) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_par(ecoL2==12.1)), GPP_par_ci(1), GPP_par_ci(2)); 
T.dGPP_SM(6) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_sm(ecoL2==12.1)), GPP_sm_ci(1), GPP_sm_ci(2)); 
T.dGPP_Tair(6) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_tair(ecoL2==12.1)), GPP_tair_ci(1), GPP_tair_ci(2)); 
T.dGPP_VPD(6) = sprintf('%.2f [%.2f, %.2f]', nanmean(GPP_vpd(ecoL2==12.1)), GPP_vpd_ci(1), GPP_vpd_ci(2)); 

%% Save figure and table
set(gcf,'PaperPositionMode','auto')
print('-dpng','-f1','-r300','./output/smap-gpp-regional-attribution.png')
print('-dtiff','-f1','-r300','./output/smap-gpp-regional-attribution.tif')
close all;

writetable(T, './output/smap_gpp_ecoregion_attribution.xlsx');
