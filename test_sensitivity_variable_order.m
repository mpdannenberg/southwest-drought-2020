% Fit climate-based GPP model and attribute to each variable


alphabet = 'abcdefghijklmnopqrstuvwxyz';
nrows = 3;
ncols = 3;

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 6];
clr = wesanderson('fantasticfox1');
ax = tight_subplot(nrows, ncols, 0.02, [0.05 0.03], [0.12 0.05]);

sites = {'US-SRG','US-SRM','US-Wkg','US-Whs','US-Mpj','US-Seg','US-Wjs','US-Ses','US-Ton'};
n = length(sites);

Tstats = table('Size',[9 7], 'VariableTypes',{'string','string','string','string','string','string','string'},...
    'VariableNames',{'Site','dGPP_SMAP','dGPP_All','dGPP_PAR','dGPP_SM','dGPP_Tair','dGPP_VPD'});
Tstats.Site = sites';

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
    
    X = cat(3, tair, vpd, par, sm);
    y = gpp;
    
    [SRM, SRMstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
        'yname','GPP', 'xnames',{'Tair','VPD','PAR','SM'},...
        'method','stepwiselm', 'modelspec','purequadratic',...
        'trainset',(tair>0), 'baseyrs',(yrs>=2015 & yrs<=2019));
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
    text(5.75, GPP_anom, 'observed','FontSize',7,'VerticalAlignment','top', 'HorizontalAlignment','right')
    hold on;
    bar(1, GPP_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
    bar(2, GPP_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
    bar(3, GPP_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
    bar(4, GPP_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
    bar(5, GPP_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
    
    Tstats.dGPP_SMAP(i) = GPP_anom;
    
    ens = mean(SRMstats.GPP_All(idx, :));
    ci = quantile(ens, [0.025 0.975]);
    plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)
    Tstats.dGPP_All(i) = sprintf('%.2f [%.2f, %.2f]', GPP_all, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 3));
    ci = quantile(ens, [0.025 0.975]);
    plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)
    Tstats.dGPP_PAR(i) = sprintf('%.2f [%.2f, %.2f]', GPP_par, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 4));
    ci = quantile(ens, [0.025 0.975]);
    plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)
    Tstats.dGPP_SM(i) = sprintf('%.2f [%.2f, %.2f]', GPP_sm, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 1));
    ci = quantile(ens, [0.025 0.975]);
    plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)
    Tstats.dGPP_Tair(i) = sprintf('%.2f [%.2f, %.2f]', GPP_tair, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 2));
    ci = quantile(ens, [0.025 0.975]);
    plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)
    Tstats.dGPP_VPD(i) = sprintf('%.2f [%.2f, %.2f]', GPP_vpd, ci(1), ci(2)); 
    
    hold off;
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
            'XLim',[0.25 5.75], 'FontSize',7)
    if i <= 3
        set(gca,'YLim',[-2.5 0.5]);
    elseif i <=6
        set(gca,'YLim',[-1 0.5]);
    elseif i <=9
        set(gca,'YLim',[-0.5 0.5]);
%     elseif i >=9
%         set(gca,'YLim',[-0.75 0.75]);
    else
        set(gca,'YLim',[-0.5 0.25]);
    end
    
    ylim = get(gca, 'YLim');
    text(0.4, ylim(2), [alphabet(i),') ', sites{i}], 'VerticalAlignment','top', 'FontWeight','bold')
    
    if i > (nrows-1)*ncols
        set(gca, 'XTickLabel',{'All','PAR','SM','T_{air}','VPD'})
        xtickangle(-20)
    else
        set(gca, 'XTickLabel','')
    end
    
    
    if rem(i, ncols) ~= 1
        set(gca, 'YTickLabel','')
    end
    
    if ceil(i/3) == 2 & rem(i, ncols) == 1
        ylabel('Mean GPP anomaly (g C m^{-2} day^{-1})', 'FontSize',10)
    end
    
end

%% Save figure
set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/supplemental-ameriflux-gpp-attribution-models-variable-order-sensitivity.tif')
close all;

