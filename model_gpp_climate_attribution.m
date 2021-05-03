% Fit climate-based GPP model and attribute to each variable

% Things to add to attribution code
    % 1) way to adjust the baseline period (relative to 2015-2020 to be
    % consistent across all sites/sensors?)
    % 2) way to adjust model calibration period (to exclude periods when
    % snow covered or T too low?)
    % 3) way to run a "simple" version based on the raw predictor variables
    % (untransformed, no lags, simple OLS)

%% SRM
T = readtable('./data/Ameriflux_monthly/US-SRM_monthly.csv');
gpp = reshape(T.GPP, 12, []);
par = reshape(T.SW_IN, 12, []);
sm = reshape(T.SWC_root, 12, []);
tair = reshape(T.TA, 12, []);
vpd = reshape(T.VPD, 12, []);
% gpp = readtable('./data/SRM_Monthly/GPP.csv', 'TreatAsEmpty','NA'); gpp = gpp{1:end, 2:end}';
% par = readtable('./data/SRM_Monthly/PAR.csv', 'TreatAsEmpty','NA'); par = par{1:end, 2:end}';
% sm = readtable('./data/SRM_Monthly/RootZone-SM.csv', 'TreatAsEmpty','NA'); sm = sm{1:end, 2:end}';
% tair = readtable('./data/SRM_Monthly/Tair.csv', 'TreatAsEmpty','NA'); tair = tair{1:end, 2:end}';
% vpd = readtable('./data/SRM_Monthly/VPD.csv', 'TreatAsEmpty','NA'); vpd = vpd{1:end, 2:end}';

X = cat(3, par, sm, tair, vpd);
y = gpp;

[SRM, SRMstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
    'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm', 'modelspec','purequadratic');
% 2020 drought
%idx = 249:252;
idx = T.Year==2020 & T.Month>=7 & T.Month<=10;
GPP_anom = mean(SRM.GPP_Obs(idx) - SRM.GPP_Avg(idx));
GPP_all = mean(SRM.GPP_All(idx) - SRM.GPP_Avg(idx));
GPP_par = mean(SRM.GPP_PAR(idx) - SRM.GPP_Avg(idx));
GPP_sm = mean(SRM.GPP_SM(idx) - SRM.GPP_Avg(idx));
GPP_tair = mean(SRM.GPP_Tair(idx) - SRM.GPP_Avg(idx));
GPP_vpd = mean(SRM.GPP_VPD(idx) - SRM.GPP_Avg(idx));

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 2.5];
clr = wesanderson('fantasticfox1');
ax = tight_subplot(1,4,0.02, [0.12 0.05], [0.1 0.05]);

axes(ax(1))
plot([0 6],[GPP_anom GPP_anom], 'k-', 'LineWidth',2)
text(4, GPP_anom, 'observed','FontSize',7,'VerticalAlignment','top')
hold on;
bar(1, GPP_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, GPP_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, GPP_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, GPP_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, GPP_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);

ens = mean(SRMstats.GPP_All(idx, :));
ci = quantile(ens, [0.025 0.975]);
plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)

ens = mean(SRMstats.BootSims(idx, :, 1));
ci = quantile(ens, [0.025 0.975]);
plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)

ens = mean(SRMstats.BootSims(idx, :, 2));
ci = quantile(ens, [0.025 0.975]);
plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)

ens = mean(SRMstats.BootSims(idx, :, 3));
ci = quantile(ens, [0.025 0.975]);
plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)

ens = mean(SRMstats.BootSims(idx, :, 4));
ci = quantile(ens, [0.025 0.975]);
plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)

hold off;

set(gca, 'TickDir','out', 'TickLength',[0.02 0], 'YLim',[-2 0.5],...
    'XLim',[0.25 5.75],'XTickLabel',{'All','PAR','SM','T_{air}','VPD'},'FontSize',7)
xtickangle(-20)
box off;
ttl = title('US-SRM','FontSize',11);
ttl.Position(2) = 0.45;

ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',10)

%% SRG
T = readtable('./data/Ameriflux_monthly/US-SRG_monthly.csv');
gpp = reshape(T.GPP, 12, []);
par = reshape(T.SW_IN, 12, []);
sm = reshape(T.SWC_root, 12, []);
tair = reshape(T.TA, 12, []);
vpd = reshape(T.VPD, 12, []);
% gpp = readtable('./data/SRG_Monthly/GPP.csv', 'TreatAsEmpty','NA'); gpp = gpp{1:end, 2:end}';
% par = readtable('./data/SRG_Monthly/PAR.csv', 'TreatAsEmpty','NA'); par = par{1:end, 2:end}';
% sm = readtable('./data/SRG_Monthly/RootZone-SM.csv', 'TreatAsEmpty','NA'); sm = sm{1:end, 2:end}';
% tair = readtable('./data/SRG_Monthly/Tair.csv', 'TreatAsEmpty','NA'); tair = tair{1:end, 2:end}';
% vpd = readtable('./data/SRG_Monthly/VPD.csv', 'TreatAsEmpty','NA'); vpd = vpd{1:end, 2:end}';

X = cat(3, par, sm, tair, vpd);
y = gpp;

[SRG, SRGstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
    'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm', 'modelspec','purequadratic');
% 2020 drought
%idx = 249:252;
idx = T.Year==2020 & T.Month>=7 & T.Month<=10;
GPP_anom = mean(SRG.GPP_Obs(idx) - SRG.GPP_Avg(idx));
GPP_all = mean(SRG.GPP_All(idx) - SRG.GPP_Avg(idx));
GPP_par = mean(SRG.GPP_PAR(idx) - SRG.GPP_Avg(idx));
GPP_sm = mean(SRG.GPP_SM(idx) - SRG.GPP_Avg(idx));
GPP_tair = mean(SRG.GPP_Tair(idx) - SRG.GPP_Avg(idx));
GPP_vpd = mean(SRG.GPP_VPD(idx) - SRG.GPP_Avg(idx));

axes(ax(2))
plot([0 6],[GPP_anom GPP_anom], 'k-', 'LineWidth',2)
text(4, GPP_anom, 'observed','FontSize',7,'VerticalAlignment','top')
hold on;
bar(1, GPP_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, GPP_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, GPP_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, GPP_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, GPP_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);

ens = mean(SRGstats.GPP_All(idx, :));
ci = quantile(ens, [0.025 0.975]);
plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)

ens = mean(SRGstats.BootSims(idx, :, 1));
ci = quantile(ens, [0.025 0.975]);
plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)

ens = mean(SRGstats.BootSims(idx, :, 2));
ci = quantile(ens, [0.025 0.975]);
plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)

ens = mean(SRGstats.BootSims(idx, :, 3));
ci = quantile(ens, [0.025 0.975]);
plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)

ens = mean(SRGstats.BootSims(idx, :, 4));
ci = quantile(ens, [0.025 0.975]);
plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)

hold off;

set(gca, 'TickDir','out', 'TickLength',[0.02 0], 'YLim',[-2 0.5],...
    'XLim',[0.25 5.75],'XTickLabel',{'All','PAR','SM','T_{air}','VPD'}, ...
    'YTickLabel','','FontSize',7)
xtickangle(-20)
box off;
ttl = title('US-SRG','FontSize',11);
ttl.Position(2) = 0.45;

%% Wkg
T = readtable('./data/Ameriflux_monthly/US-Wkg_monthly.csv');
gpp = reshape(T.GPP, 12, []);
par = reshape(T.SW_IN, 12, []);
sm = reshape(T.SWC_root, 12, []);
tair = reshape(T.TA, 12, []);
vpd = reshape(T.VPD, 12, []);
% gpp = readtable('./data/Wkg_Monthly/GPP.csv', 'TreatAsEmpty','NA'); gpp = gpp{1:end, 2:end}';
% par = readtable('./data/Wkg_Monthly/PAR.csv', 'TreatAsEmpty','NA'); par = par{1:end, 2:end}';
% sm = readtable('./data/Wkg_Monthly/RootZone-SM.csv', 'TreatAsEmpty','NA'); sm = sm{1:end, 2:end}';
% tair = readtable('./data/Wkg_Monthly/Tair.csv', 'TreatAsEmpty','NA'); tair = tair{1:end, 2:end}';
% vpd = readtable('./data/Wkg_Monthly/VPD.csv', 'TreatAsEmpty','NA'); vpd = vpd{1:end, 2:end}';

X = cat(3, par, sm, tair, vpd);
y = gpp;

[Wkg, Wkgstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
    'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm', 'modelspec','purequadratic');
% 2020 drought
%idx = 249:252;
idx = T.Year==2020 & T.Month>=7 & T.Month<=10;
GPP_anom = mean(Wkg.GPP_Obs(idx) - Wkg.GPP_Avg(idx));
GPP_all = mean(Wkg.GPP_All(idx) - Wkg.GPP_Avg(idx));
GPP_par = mean(Wkg.GPP_PAR(idx) - Wkg.GPP_Avg(idx));
GPP_sm = mean(Wkg.GPP_SM(idx) - Wkg.GPP_Avg(idx));
GPP_tair = mean(Wkg.GPP_Tair(idx) - Wkg.GPP_Avg(idx));
GPP_vpd = mean(Wkg.GPP_VPD(idx) - Wkg.GPP_Avg(idx));

axes(ax(3))
plot([0 6],[GPP_anom GPP_anom], 'k-', 'LineWidth',2)
text(4, GPP_anom, 'observed','FontSize',7,'VerticalAlignment','top')
hold on;
bar(1, GPP_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, GPP_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, GPP_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, GPP_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, GPP_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);

ens = mean(Wkgstats.GPP_All(idx, :));
ci = quantile(ens, [0.025 0.975]);
plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)

ens = mean(Wkgstats.BootSims(idx, :, 1));
ci = quantile(ens, [0.025 0.975]);
plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)

ens = mean(Wkgstats.BootSims(idx, :, 2));
ci = quantile(ens, [0.025 0.975]);
plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)

ens = mean(Wkgstats.BootSims(idx, :, 3));
ci = quantile(ens, [0.025 0.975]);
plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)

ens = mean(Wkgstats.BootSims(idx, :, 4));
ci = quantile(ens, [0.025 0.975]);
plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)

hold off;

set(gca, 'TickDir','out', 'TickLength',[0.02 0], 'YLim',[-2 0.5],...
    'XLim',[0.25 5.75],'XTickLabel',{'All','PAR','SM','T_{air}','VPD'}, ...
    'YTickLabel','','FontSize',7)
xtickangle(-20)
box off;
ttl = title('US-Wkg','FontSize',11);
ttl.Position(2) = 0.45;

%% Whs
T = readtable('./data/Ameriflux_monthly/US-Whs_monthly.csv');
gpp = reshape(T.GPP, 12, []);
par = reshape(T.SW_IN, 12, []);
sm = reshape(T.SWC_root, 12, []);
tair = reshape(T.TA, 12, []);
vpd = reshape(T.VPD, 12, []);
% gpp = readtable('./data/Whs_Monthly/GPP.csv', 'TreatAsEmpty','NA'); gpp = gpp{1:end, 2:end}';
% par = readtable('./data/Whs_Monthly/PAR.csv', 'TreatAsEmpty','NA'); par = par{1:end, 2:end}';
% sm = readtable('./data/Whs_Monthly/RootZone-SM.csv', 'TreatAsEmpty','NA'); sm = sm{1:end, 2:end}';
% tair = readtable('./data/Whs_Monthly/Tair.csv', 'TreatAsEmpty','NA'); tair = tair{1:end, 2:end}';
% vpd = readtable('./data/Whs_Monthly/VPD.csv', 'TreatAsEmpty','NA'); vpd = vpd{1:end, 2:end}';

X = cat(3, par, sm, tair, vpd);
y = gpp;

[Whs, Whsstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
    'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm', 'modelspec','purequadratic');
% 2020 drought
%idx = 249:252;
idx = T.Year==2020 & T.Month>=7 & T.Month<=10;
GPP_anom = mean(Whs.GPP_Obs(idx) - Whs.GPP_Avg(idx));
GPP_all = mean(Whs.GPP_All(idx) - Whs.GPP_Avg(idx));
GPP_par = mean(Whs.GPP_PAR(idx) - Whs.GPP_Avg(idx));
GPP_sm = mean(Whs.GPP_SM(idx) - Whs.GPP_Avg(idx));
GPP_tair = mean(Whs.GPP_Tair(idx) - Whs.GPP_Avg(idx));
GPP_vpd = mean(Whs.GPP_VPD(idx) - Whs.GPP_Avg(idx));

axes(ax(4))
plot([0 6],[GPP_anom GPP_anom], 'k-', 'LineWidth',2)
text(4, GPP_anom, 'observed','FontSize',7,'VerticalAlignment','top')
hold on;
bar(1, GPP_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
bar(2, GPP_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
bar(3, GPP_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
bar(4, GPP_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
bar(5, GPP_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);

ens = mean(Whsstats.GPP_All(idx, :));
ci = quantile(ens, [0.025 0.975]);
plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)

ens = mean(Whsstats.BootSims(idx, :, 1));
ci = quantile(ens, [0.025 0.975]);
plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)

ens = mean(Whsstats.BootSims(idx, :, 2));
ci = quantile(ens, [0.025 0.975]);
plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)

ens = mean(Whsstats.BootSims(idx, :, 3));
ci = quantile(ens, [0.025 0.975]);
plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)

ens = mean(Whsstats.BootSims(idx, :, 4));
ci = quantile(ens, [0.025 0.975]);
plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)

hold off;

set(gca, 'TickDir','out', 'TickLength',[0.02 0], 'YLim',[-2 0.5],...
    'XLim',[0.25 5.75],'XTickLabel',{'All','PAR','SM','T_{air}','VPD'}, ...
    'YTickLabel','','FontSize',7)
xtickangle(-20)
box off;
ttl = title('US-Whs','FontSize',11);
ttl.Position(2) = 0.45;

% %% MtB
% gpp = readtable('./data/MTB_Monthly/GPP.csv', 'TreatAsEmpty','NA'); gpp = gpp{1:end, 2:end}';
% par = readtable('./data/MTB_Monthly/PAR.csv', 'TreatAsEmpty','NA'); par = par{1:end, 2:end}';
% sm = readtable('./data/MTB_Monthly/RootZone-SM.csv', 'TreatAsEmpty','NA'); sm = sm{1:end, 2:end}';
% tair = readtable('./data/MTB_Monthly/Tair.csv', 'TreatAsEmpty','NA'); tair = tair{1:end, 2:end}';
% vpd = readtable('./data/MTB_Monthly/VPD.csv', 'TreatAsEmpty','NA'); vpd = vpd{1:end, 2:end}';
% 
% X = cat(3, par, sm, tair, vpd);
% y = gpp;
% 
% [MTB, MTBstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
%     'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},'method','stepwiselm', 'modelspec','purequadratic');
% % 2020 drought
% idx = 249:252;
% GPP_anom = mean(MTB.GPP_Obs(idx) - MTB.GPP_Avg(idx));
% GPP_all = mean(MTB.GPP_All(idx) - MTB.GPP_Avg(idx));
% GPP_par = mean(MTB.GPP_PAR(idx) - MTB.GPP_Avg(idx));
% GPP_sm = mean(MTB.GPP_SM(idx) - MTB.GPP_Avg(idx));
% GPP_tair = mean(MTB.GPP_Tair(idx) - MTB.GPP_Avg(idx));
% GPP_vpd = mean(MTB.GPP_VPD(idx) - MTB.GPP_Avg(idx));
% 
% axes(ax(5))
% plot([0 6],[GPP_anom GPP_anom], 'k-', 'LineWidth',2)
% text(4, GPP_anom, 'observed','FontSize',7,'VerticalAlignment','top')
% hold on;
% bar(1, GPP_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
% bar(2, GPP_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
% bar(3, GPP_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
% bar(4, GPP_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
% bar(5, GPP_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
% 
% ens = mean(MTBstats.GPP_All(idx, :));
% ci = quantile(ens, [0.025 0.975]);
% plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)
% 
% ens = mean(MTBstats.BootSims(idx, :, 1));
% ci = quantile(ens, [0.025 0.975]);
% plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)
% 
% ens = mean(MTBstats.BootSims(idx, :, 2));
% ci = quantile(ens, [0.025 0.975]);
% plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)
% 
% ens = mean(MTBstats.BootSims(idx, :, 3));
% ci = quantile(ens, [0.025 0.975]);
% plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)
% 
% ens = mean(MTBstats.BootSims(idx, :, 4));
% ci = quantile(ens, [0.025 0.975]);
% plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)
% 
% hold off;
% 
% set(gca, 'TickDir','out', 'TickLength',[0.02 0], 'YLim',[-2 0.5],...
%     'XLim',[0.25 5.75],'XTickLabel',{'All','PAR','SM','T_{air}','VPD'}, ...
%     'YTickLabel','','FontSize',7)
% xtickangle(-20)
% box off;
% ttl = title('US-MtB','FontSize',11);
% ttl.Position(2) = 0.45;

set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/gpp-attribution-models-stepwise-quadratic-interactions-wMtB.tif')
close all;

%% Plot time series
% h = figure('Color','w');
% h.Units = 'inches';
% h.Position = [1 1 6.5 4];
% 
% yr = reshape(repmat(2000:2020,12,1), [],1);
% mo = repmat(1:12,1,length(2000:2020))';
% dt = datenum(yr, mo, 15) - 61;
% [Year, Month] = datevec(dt);
% 
% SRM = addvars(SRM, Year, Month, 'before',1);
% Wkg = addvars(Wkg, Year, Month, 'before',1);
% 
% plot(dt, SRM.GPP_Obs, 'k-', 'LineWidth',1.5)
% hold on;
% plot(dt, SRM.GPP_PAR, '-', 'LineWidth',1.5, 'Color',clr(1,:))
% plot(dt, SRM.GPP_SM, '-', 'LineWidth',1.5, 'Color',clr(4,:))
% plot(dt, SRM.GPP_Tair, '-', 'LineWidth',1.5, 'Color',clr(3,:))
% plot(dt, SRM.GPP_VPD, '-', 'LineWidth',1.5, 'Color',clr(2,:))
% 
% writetable(SRM, './output/SRM_GPP_attribution.xlsx');
% writetable(Wkg, './output/Wkg_GPP_attribution.xlsx');
% 
% %% Plot validation
% h = figure('Color','w');
% h.Units = 'inches';
% h.Position = [1 1 6.5 6];
% 
% subplot(2,2,1)
% plot(SRM.GPP_Obs, SRM.GPP_All, 'ko')
% set(gca, 'XLim',[-1 6], 'YLim',[-1 6], 'TickDir','out', 'TickLength',[0.02 0])
% box off;
% hold on;
% plot([-1 6], [-1 6], '--', 'Color',[0.5 0.5 0.5]);
% r = corr(SRM.GPP_Obs, SRM.GPP_All, 'rows','pairwise')^2;
% text(-0.8, 6, ['R^{2} = ',num2str(round(r, 2))])
% ylabel('Modeled GPP (g C m^{-2} day^{-1})', 'FontSize',9);
% xlabel('Observed GPP (g C m^{-2} day^{-1})', 'FontSize',9);
% title('SRM','FontSize',12)
% 
% subplot(2,2,3)
% plot(SRM.GPP_Obs-SRM.GPP_Avg, SRM.GPP_All-SRM.GPP_Avg, 'ko')
% set(gca, 'XLim',[-3 3], 'YLim',[-3 3], 'TickDir','out', 'TickLength',[0.02 0])
% box off;
% hold on;
% plot([-3 3], [-3 3], '--', 'Color',[0.5 0.5 0.5]);
% r = corr(SRM.GPP_Obs-SRM.GPP_Avg, SRM.GPP_All-SRM.GPP_Avg, 'rows','pairwise')^2;
% text(-2.8, 3, ['R^{2} = ',num2str(round(r, 2))])
% ylabel('Modeled GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',9);
% xlabel('Observed GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',9);
% 
% subplot(2,2,2)
% plot(Wkg.GPP_Obs, Wkg.GPP_All, 'ko')
% set(gca, 'XLim',[-1 6], 'YLim',[-1 6], 'TickDir','out', 'TickLength',[0.02 0])
% box off;
% hold on;
% plot([-1 6], [-1 6], '--', 'Color',[0.5 0.5 0.5]);
% r = corr(Wkg.GPP_Obs, Wkg.GPP_All, 'rows','pairwise')^2;
% text(-0.8, 6, ['R^{2} = ',num2str(round(r, 2))])
% ylabel('Modeled GPP (g C m^{-2} day^{-1})', 'FontSize',9);
% xlabel('Observed GPP (g C m^{-2} day^{-1})', 'FontSize',9);
% title('Wkg','FontSize',12)
% 
% subplot(2,2,4)
% plot(Wkg.GPP_Obs-Wkg.GPP_Avg, Wkg.GPP_All-Wkg.GPP_Avg, 'ko')
% set(gca, 'XLim',[-3 3], 'YLim',[-3 3], 'TickDir','out', 'TickLength',[0.02 0])
% box off;
% hold on;
% plot([-3 3], [-3 3], '--', 'Color',[0.5 0.5 0.5]);
% r = corr(Wkg.GPP_Obs-Wkg.GPP_Avg, Wkg.GPP_All-Wkg.GPP_Avg, 'rows','pairwise')^2;
% text(-2.8, 3, ['R^{2} = ',num2str(round(r, 2))])
% ylabel('Modeled GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',9);
% xlabel('Observed GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',9);
% 
% set(gcf,'PaperPositionMode','auto')
% print('-dtiff','-f1','-r300','./output/srm-wkg-gpp-attribution-models.tif')
% close all;
% 

