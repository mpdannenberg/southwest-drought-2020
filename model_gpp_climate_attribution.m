% Fit climate-based GPP model and attribute to each variable

% Things to add to attribution code
    % 1) way to adjust the baseline period (relative to 2015-2020 to be
    % consistent across all sites/sensors?)
    % 2) way to adjust model calibration period (to exclude periods when
    % snow covered or T too low?)
    % 3) way to run a "simple" version based on the raw predictor variables
    % (untransformed, no lags, simple OLS)

nrows = 3;
ncols = 3;

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 6];
clr = wesanderson('fantasticfox1');
ax = tight_subplot(nrows, ncols, 0.02, [0.12 0.05], [0.1 0.05]);

sites = {'US-SRG','US-SRM','US-Vcp','US-Wkg','US-Mpj','US-Whs','US-Seg','US-Ses','US-Wjs'};
n = length(sites);

%% Loop through sites and add to figure
for i = 1:n
    fn = glob(['./data/Ameriflux_monthly/',sites{i},'*.csv']);

    T = readtable(fn{1});
    gpp = reshape(T.GPP, 12, []);
    par = reshape(T.SW_IN, 12, []);
    sm = reshape(T.SWC_root, 12, []);
    tair = reshape(T.TA, 12, []);
    tmin = reshape(T.Tmin, 12, []);
    vpd = reshape(T.VPD, 12, []);
    yrs = unique(T.Year);
    
    X = cat(3, par, sm, tair, vpd);
    y = gpp;
    
    [SRM, SRMstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
        'yname','GPP', 'xnames',{'PAR','SM','Tair','VPD'},...
        'method','stepwiselm', 'modelspec','purequadratic',...
        'trainset',(tmin>0), 'baseyrs',(yrs>=2015 & yrs<=2020));
    % 2020 drought
    idx = T.Year==2020 & T.Month>=7 & T.Month<=10;
    GPP_anom = mean(SRM.GPP_Obs(idx) - SRM.GPP_Avg(idx));
    GPP_all = mean(SRM.GPP_All(idx) - SRM.GPP_Avg(idx));
    GPP_par = mean(SRM.GPP_PAR(idx) - SRM.GPP_Avg(idx));
    GPP_sm = mean(SRM.GPP_SM(idx) - SRM.GPP_Avg(idx));
    GPP_tair = mean(SRM.GPP_Tair(idx) - SRM.GPP_Avg(idx));
    GPP_vpd = mean(SRM.GPP_VPD(idx) - SRM.GPP_Avg(idx));
    
    axes(ax(i))
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
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
            'XLim',[0.25 5.75], 'FontSize',7)
    if i <= 3
        set(gca,'YLim',[-2 0.5]);
    elseif i <=6
        set(gca,'YLim',[-1.5 0.5]);
    else
        set(gca,'YLim',[-1 0.25]);
    end
        
    if i > (nrows-1)*ncols
        set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
        xtickangle(-20)
    else
        set(gca, 'XTickLabel','')
    end
    
    ttl = title([sites{i}],'FontSize',10);
    ttl.Position(2) = 0.25;
    
    if rem(i, ncols) == 1
        ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',7)
    else
        set(gca, 'YTickLabel','')
    end
    
end

%% Save figure
set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/ameriflux-gpp-attribution-models.tif')
close all;

