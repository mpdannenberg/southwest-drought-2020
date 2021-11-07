% Plot GPP anomaly attribution by land cover type
alphabet = 'abcdefghijklmnopqrstuvwxyz';
nrows = 4;
ncols = 4;
ndays = 31 + 31 + 30 + 31; % Total number of days (for conversion from gC m-2 day-1 to gC m-2)

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 5.5];
ax = tight_subplot(nrows, ncols, [0.04 0.04], [0.08 0.08], [0.1 0.05]);

clr = wesanderson('fantasticfox1');

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

%% Initiate table
T = table('Size',[6 7], 'VariableTypes',{'string','string','string','string','string','string','string'},...
    'VariableNames',{'Ecoregion','dGPP_SMAP','dGPP_All','dGPP_PAR','dGPP_SM','dGPP_Tair','dGPP_VPD'});
T.Ecoregion = {'Cold Deserts','Warm Deserts','Mediterranean California','Semiarid Prairies','Upper Gila Mountains','Sierra Madre Piedmont'}';

%% Add EcoRegions 
load ./data/ecoregions.mat;
eco_bounds(isnan(GPP_obs) | isnan(eco_bounds)) = 0;
GPP_obs(eco_bounds==0) = NaN;

%% Add bar plots by ecoregion
% Cold deserts
axes(ax(1))
plot([0 6],[ndays*nanmean(GPP_obs(ecoL2==10.1)) ndays*nanmean(GPP_obs(ecoL2==10.1))], 'k-', 'LineWidth',2)
text(3, ndays*nanmean(GPP_obs(ecoL2==10.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, ndays*nanmean(GPP_all(ecoL2==10.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, ndays*nanmean(GPP_par(ecoL2==10.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, ndays*nanmean(GPP_sm(ecoL2==10.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, ndays*nanmean(GPP_tair(ecoL2==10.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, ndays*nanmean(GPP_vpd(ecoL2==10.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, ecoL2==10.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25,...
        'YTickLabel',{'','-100','','-50','','0',''})
set(gca, 'XTickLabel',{'','','','',''})
ylim = get(gca,'YLim');
text(0.5, ylim(2), 'a) Cold deserts', 'FontSize',8);

T.dGPP_SMAP(1) = num2str(round(ndays*nanmean(GPP_obs(ecoL2==10.1))));
T.dGPP_All(1) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_all(ecoL2==10.1))), round(GPP_all_ci(1)), round(GPP_all_ci(2))); 
T.dGPP_PAR(1) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_par(ecoL2==10.1))), round(GPP_par_ci(1)), round(GPP_par_ci(2))); 
T.dGPP_SM(1) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_sm(ecoL2==10.1))), round(GPP_sm_ci(1)), round(GPP_sm_ci(2))); 
T.dGPP_Tair(1) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_tair(ecoL2==10.1))), round(GPP_tair_ci(1)), round(GPP_tair_ci(2))); 
T.dGPP_VPD(1) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_vpd(ecoL2==10.1))), round(GPP_vpd_ci(1)), round(GPP_vpd_ci(2))); 

% Mediterranean California
axes(ax(2))
plot([0 6],[ndays*nanmean(GPP_obs(ecoL2==11.1)) ndays*nanmean(GPP_obs(ecoL2==11.1))], 'k-', 'LineWidth',2)
text(3, ndays*nanmean(GPP_obs(ecoL2==11.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, ndays*nanmean(GPP_all(ecoL2==11.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, ndays*nanmean(GPP_par(ecoL2==11.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, ndays*nanmean(GPP_sm(ecoL2==11.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, ndays*nanmean(GPP_tair(ecoL2==11.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, ndays*nanmean(GPP_vpd(ecoL2==11.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, ecoL2==11.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25,...
        'YTickLabel',{'','-100','','-50','','0',''})
set(gca, 'XTickLabel',{'','','','',''}, 'YTickLabel',{'','','','',''})
ylim = get(gca,'YLim');
text(0.5, ylim(2), 'b) Mediterranean CA', 'FontSize',8);

T.dGPP_SMAP(3) = num2str(round(ndays*nanmean(GPP_obs(ecoL2==11.1))));
T.dGPP_All(3) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_all(ecoL2==11.1))), round(GPP_all_ci(1)), round(GPP_all_ci(2))); 
T.dGPP_PAR(3) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_par(ecoL2==11.1))), round(GPP_par_ci(1)), round(GPP_par_ci(2))); 
T.dGPP_SM(3) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_sm(ecoL2==11.1))), round(GPP_sm_ci(1)), round(GPP_sm_ci(2))); 
T.dGPP_Tair(3) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_tair(ecoL2==11.1))), round(GPP_tair_ci(1)), round(GPP_tair_ci(2))); 
T.dGPP_VPD(3) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_vpd(ecoL2==11.1))), round(GPP_vpd_ci(1)), round(GPP_vpd_ci(2))); 

% Warm deserts
axes(ax(5))
plot([0 6],[ndays*nanmean(GPP_obs(ecoL2==10.2)) ndays*nanmean(GPP_obs(ecoL2==10.2))], 'k-', 'LineWidth',2)
text(3, ndays*nanmean(GPP_obs(ecoL2==10.2)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, ndays*nanmean(GPP_all(ecoL2==10.2)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, ndays*nanmean(GPP_par(ecoL2==10.2)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, ndays*nanmean(GPP_sm(ecoL2==10.2)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, ndays*nanmean(GPP_tair(ecoL2==10.2)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, ndays*nanmean(GPP_vpd(ecoL2==10.2)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, ecoL2==10.2), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25,...
        'YTickLabel',{'','-100','','-50','','0',''})
set(gca, 'XTickLabel',{'','','','',''})
ylim = get(gca,'YLim');
text(0.5, ylim(2), 'c) Warm deserts', 'FontSize',8);
ylabel('July-October GPP anomaly (g C m^{-2})', 'FontSize',10)

T.dGPP_SMAP(2) = num2str(round(ndays*nanmean(GPP_obs(ecoL2==10.2))));
T.dGPP_All(2) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_all(ecoL2==10.2))), round(GPP_all_ci(1)), round(GPP_all_ci(2))); 
T.dGPP_PAR(2) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_par(ecoL2==10.2))), round(GPP_par_ci(1)), round(GPP_par_ci(2))); 
T.dGPP_SM(2) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_sm(ecoL2==10.2))), round(GPP_sm_ci(1)), round(GPP_sm_ci(2))); 
T.dGPP_Tair(2) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_tair(ecoL2==10.2))), round(GPP_tair_ci(1)), round(GPP_tair_ci(2))); 
T.dGPP_VPD(2) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_vpd(ecoL2==10.2))), round(GPP_vpd_ci(1)), round(GPP_vpd_ci(2))); 

% Semiarid prairies
axes(ax(6))
plot([0 6],[ndays*nanmean(GPP_obs(ecoL2==9.4)) ndays*nanmean(GPP_obs(ecoL2==9.4))], 'k-', 'LineWidth',2)
text(3, ndays*nanmean(GPP_obs(ecoL2==9.4)), 'SMAP L4C','FontSize',7,'VerticalAlignment','bottom','HorizontalAlignment','center')
hold on;
bar(1, ndays*nanmean(GPP_all(ecoL2==9.4)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, ndays*nanmean(GPP_par(ecoL2==9.4)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, ndays*nanmean(GPP_sm(ecoL2==9.4)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, ndays*nanmean(GPP_tair(ecoL2==9.4)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, ndays*nanmean(GPP_vpd(ecoL2==9.4)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, ecoL2==9.4), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25,...
        'YTickLabel',{'','-100','','-50','','0',''})
set(gca, 'XTickLabel',{'','','','',''}, 'YTickLabel',{'','','','',''})
ylim = get(gca,'YLim');
text(0.5, ylim(2), 'd) Semiarid prairies', 'FontSize',8);

T.dGPP_SMAP(4) = num2str(round(ndays*nanmean(GPP_obs(ecoL2==9.4))));
T.dGPP_All(4) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_all(ecoL2==9.4))), round(GPP_all_ci(1)), round(GPP_all_ci(2))); 
T.dGPP_PAR(4) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_par(ecoL2==9.4))), round(GPP_par_ci(1)), round(GPP_par_ci(2))); 
T.dGPP_SM(4) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_sm(ecoL2==9.4))), round(GPP_sm_ci(1)), round(GPP_sm_ci(2))); 
T.dGPP_Tair(4) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_tair(ecoL2==9.4))), round(GPP_tair_ci(1)), round(GPP_tair_ci(2))); 
T.dGPP_VPD(4) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_vpd(ecoL2==9.4))), round(GPP_vpd_ci(1)), round(GPP_vpd_ci(2))); 

% Upper Gila Mountains
axes(ax(9))
plot([0 6],[ndays*nanmean(GPP_obs(ecoL2==13.1)) ndays*nanmean(GPP_obs(ecoL2==13.1))], 'k-', 'LineWidth',2)
text(3, ndays*nanmean(GPP_obs(ecoL2==13.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','top','HorizontalAlignment','center')
hold on;
bar(1, ndays*nanmean(GPP_all(ecoL2==13.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, ndays*nanmean(GPP_par(ecoL2==13.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, ndays*nanmean(GPP_sm(ecoL2==13.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, ndays*nanmean(GPP_tair(ecoL2==13.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, ndays*nanmean(GPP_vpd(ecoL2==13.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, ecoL2==13.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25,...
        'YTickLabel',{'','-100','','-50','','0',''})
set(gca, 'XTick',1:5,'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-30)
ylim = get(gca,'YLim');
text(0.5, ylim(2), 'e) Upper Gila Mtns.', 'FontSize',8);

T.dGPP_SMAP(5) = num2str(round(ndays*nanmean(GPP_obs(ecoL2==13.1))));
T.dGPP_All(5) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_all(ecoL2==13.1))), round(GPP_all_ci(1)), round(GPP_all_ci(2))); 
T.dGPP_PAR(5) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_par(ecoL2==13.1))), round(GPP_par_ci(1)), round(GPP_par_ci(2))); 
T.dGPP_SM(5) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_sm(ecoL2==13.1))), round(GPP_sm_ci(1)), round(GPP_sm_ci(2))); 
T.dGPP_Tair(5) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_tair(ecoL2==13.1))), round(GPP_tair_ci(1)), round(GPP_tair_ci(2))); 
T.dGPP_VPD(5) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_vpd(ecoL2==13.1))), round(GPP_vpd_ci(1)), round(GPP_vpd_ci(2))); 

% Sierra Madre Piedmont
axes(ax(10))
plot([0 6],[ndays*nanmean(GPP_obs(ecoL2==12.1)) ndays*nanmean(GPP_obs(ecoL2==12.1))], 'k-', 'LineWidth',2)
text(3, ndays*nanmean(GPP_obs(ecoL2==12.1)), 'SMAP L4C','FontSize',7,'VerticalAlignment','bottom','HorizontalAlignment','center')
hold on;
bar(1, ndays*nanmean(GPP_all(ecoL2==12.1)), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, ndays*nanmean(GPP_par(ecoL2==12.1)), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, ndays*nanmean(GPP_sm(ecoL2==12.1)), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, ndays*nanmean(GPP_tair(ecoL2==12.1)), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, ndays*nanmean(GPP_vpd(ecoL2==12.1)), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, ecoL2==12.1), 2), [0.025 0.975]);
plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
hold off;
box off;
set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
        'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25,...
        'YTickLabel',{'','','','',''})
set(gca, 'XTick',1:5,'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
xtickangle(-30)
ylim = get(gca,'YLim');
text(0.5, ylim(2), 'f) Sierra Madre piedmont', 'FontSize',8);

T.dGPP_SMAP(6) = num2str(round(ndays*nanmean(GPP_obs(ecoL2==12.1))));
T.dGPP_All(6) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_all(ecoL2==12.1))), round(GPP_all_ci(1)), round(GPP_all_ci(2))); 
T.dGPP_PAR(6) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_par(ecoL2==12.1))), round(GPP_par_ci(1)), round(GPP_par_ci(2))); 
T.dGPP_SM(6) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_sm(ecoL2==12.1))), round(GPP_sm_ci(1)), round(GPP_sm_ci(2))); 
T.dGPP_Tair(6) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_tair(ecoL2==12.1))), round(GPP_tair_ci(1)), round(GPP_tair_ci(2))); 
T.dGPP_VPD(6) = sprintf('%d [%d, %d]', round(ndays*nanmean(GPP_vpd(ecoL2==12.1))), round(GPP_vpd_ci(1)), round(GPP_vpd_ci(2))); 

% Empty subplots
axes(ax(13))
axis off;

axes(ax(14))
axis off;

% Separator and Main label
annotation("line",[0.53 0.53],[0.025 0.975], 'LineWidth',2)
annotation("textbox",[0.1 0.92 0.425 0.08],'String','Ecoregion','EdgeColor','none',...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold')

%% Read in land cover data
load ./data/rangeland.mat;
rangeland(rangeland == 6) = NaN; % No northwestern croplands
rangeland(rangeland == 7) = 6; % Reclassify remaining croplands
rangeland(rangeland == 8) = 7;
lc = {'Forest','Shrubland','Savanna','Annual','Perennial','Crop (SW)','Crop (plains)'};

%% Exclude water and LC outside ecoregion bounds
rangeland(rangeland==0 | isnan(eco_bounds) | eco_bounds == 0) = NaN;

%% Add bar plots by land cover
axidx = [3 4 7 8 11 12 16];
for i = 1:length(lc)
    
    axes(ax(axidx(i)))
    
    plot([0 6],[ndays*nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2))) ndays*nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2)))], 'k-', 'LineWidth',2)
    if i ~= 4 & i ~= 6
        text(5.75, ndays*nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2))), 'SMAP L4C','FontSize',7,'VerticalAlignment','bottom', 'HorizontalAlignment','right')
    else
        text(5.75, ndays*nanmean(GPP_obs(rangeland==i & ~isnan(ecoL2))), 'SMAP L4C','FontSize',7,'VerticalAlignment','top', 'HorizontalAlignment','right')
    end
    hold on;
    bar(1, ndays*nanmean(GPP_all(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
    bar(2, ndays*nanmean(GPP_par(rangeland==i & ~isnan(ecoL2))), 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
    bar(3, ndays*nanmean(GPP_sm(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
    bar(4, ndays*nanmean(GPP_tair(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
    bar(5, ndays*nanmean(GPP_vpd(rangeland==i & ~isnan(ecoL2))), 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
    GPP_all_ci = quantile(ndays*nanmean(GPP_all_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_par_ci = quantile(ndays*nanmean(GPP_par_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_sm_ci = quantile(ndays*nanmean(GPP_sm_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_tair_ci = quantile(ndays*nanmean(GPP_tair_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    GPP_vpd_ci = quantile(ndays*nanmean(GPP_vpd_ens(:, rangeland==i & ~isnan(ecoL2)), 2), [0.025 0.975]);
    plot([1 1], [GPP_all_ci(1) GPP_all_ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5);
    plot([2 2], [GPP_par_ci(1) GPP_par_ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5);
    plot([3 3], [GPP_sm_ci(1) GPP_sm_ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5);
    plot([4 4], [GPP_tair_ci(1) GPP_tair_ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5);
    plot([5 5], [GPP_vpd_ci(1) GPP_vpd_ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5);
    hold off;
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
            'XLim',[0.25 5.75], 'FontSize',8, 'YLim',[-125 25], 'YTick',-125:25:25)
        
    if i == 5 | i == 7
        set(gca,'XTick',1:5, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'},'FontSize',8)
        xtickangle(-30)
    else
        set(gca, 'XTickLabel','')
    end
    
    if i~=7
        set(gca, 'YTickLabel','')
    else
        set(gca, 'YTickLabel',{'','-100','','-50','','0',''})
    end
    
    ylim = get(gca,'YLim');
    text(0.5, ylim(2), [alphabet(i+6),') ',lc{i}], 'FontSize',8);
    
end

axes(ax(15))
axis off;

annotation("textbox",[0.53 0.92 0.425 0.08],'String','Land cover','EdgeColor','none',...
    'HorizontalAlignment','center', 'FontSize',12, 'FontWeight','bold')

set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/smap-gpp-ecoregion-lc-attribution.tif')
close all;

writetable(T, './output/smap_gpp_ecoregion_attribution.xlsx');
