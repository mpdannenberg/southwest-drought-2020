% Plot SMAP attribution at each Ameriflux site (for comparison to the
% actual Ameriflux attribution)

alphabet = 'abcdefghijklmnopqrstuvwxyz';
nrows = 3;
ncols = 3;

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 6.5 6];
clr = wesanderson('fantasticfox1');
ax = tight_subplot(nrows, ncols, 0.02, [0.05 0.03], [0.12 0.05]);

sites = {'US-SRG','US-SRM','US-Wkg','US-Whs','US-Mpj','US-Seg','US-Wjs','US-Ses','US-Ton'};
flat = [31.7894 31.8214 31.7365 31.7438 34.4385 34.3623 34.4255 34.3349 38.4309];
flon = [-110.8277 -110.8661 -109.9419 -110.0522 -106.2377 -106.7019 -105.8615 -106.7442 -120.966];
n = length(sites);

Tstats = table('Size',[9 7], 'VariableTypes',{'string','string','string','string','string','string','string'},...
    'VariableNames',{'Site','dCSIF','dCSIF_All','dCSIF_PAR','dCSIF_SM','dCSIF_Tair','dCSIF_VPD'});
Tstats.Site = sites';

load ./data/CSIF_monthly.mat;

%% Loop through sites and add to figure
for i = 1:n
    fn = glob(['./data/Ameriflux_monthly/',sites{i},'*.csv']);
    T = readtable(fn{1});
    
    latidx = find(abs(lat - flat(i)) == min(abs(lat - flat(i))));
    lonidx = find(abs(lon - flon(i)) == min(abs(lon - flon(i))));
    tstart = find(T.Year == yr(1) & T.Month == mo(1));
    tend = find(T.Year == yr(end) & T.Month == mo(end));

    gpp = NaN(size(T.GPP)); 
    gpp(tstart:tend) = CSIF_monthly(latidx, lonidx, :);
    gpp = reshape(gpp, 12, []);
    par = reshape(T.SW_IN, 12, []);
    sm = reshape(T.SWC_root, 12, []);
    tair = reshape(T.TA, 12, []);
    tmin = reshape(T.Tmin, 12, []);
    vpd = reshape(T.VPD, 12, []);
    yrs = unique(T.Year);
    
    X = cat(3, par, sm, tair, vpd);
    y = gpp;
    
    [SRM, SRMstats] = anomaly_attribution(y, X, 'nsims',1000,'nlags',1,...
        'yname','CSIF', 'xnames',{'PAR','SM','Tair','VPD'},...
        'method','stepwiselm', 'modelspec','purequadratic',...
        'trainset',(tair>0), 'baseyrs',(yrs>=2015 & yrs<=2019));
    % 2020 drought
    idx = T.Year==2020 & T.Month>=7 & T.Month<=10;
    CSIF_anom = mean(SRM.CSIF_Obs(idx) - SRM.CSIF_Avg(idx));
    CSIF_all = mean(SRM.CSIF_All(idx) - SRM.CSIF_Avg(idx));
    CSIF_par = mean(SRM.CSIF_PAR(idx) - SRM.CSIF_Avg(idx));
    CSIF_sm = mean(SRM.CSIF_SM(idx) - SRM.CSIF_Avg(idx));
    CSIF_tair = mean(SRM.CSIF_Tair(idx) - SRM.CSIF_Avg(idx));
    CSIF_vpd = mean(SRM.CSIF_VPD(idx) - SRM.CSIF_Avg(idx));
    
    axes(ax(i))
    plot([0 6],[CSIF_anom CSIF_anom], 'k-', 'LineWidth',2)
    if i==5 | i==6 | i==8
        text(5.75, CSIF_anom, 'CSIF anomaly','FontSize',7,'VerticalAlignment','bottom', 'HorizontalAlignment','right')
    elseif i==9
        text(3, CSIF_anom, 'CSIF anomaly','FontSize',7,'VerticalAlignment','top', 'HorizontalAlignment','center')
    else
        text(5.75, CSIF_anom, 'CSIF anomaly','FontSize',7,'VerticalAlignment','top', 'HorizontalAlignment','right')
    end
    hold on;
    bar(1, CSIF_all, 'FaceColor',clr(5,:), 'EdgeColor',clr(5,:).^2, 'LineWidth',1.5);
    bar(2, CSIF_par, 'FaceColor',sqrt(clr(4,:)), 'EdgeColor',clr(4,:).^2, 'LineWidth',1.5);
    bar(3, CSIF_sm, 'FaceColor',clr(3,:), 'EdgeColor',clr(3,:).^2, 'LineWidth',1.5);
    bar(4, CSIF_tair, 'FaceColor',clr(1,:), 'EdgeColor',clr(1,:).^2, 'LineWidth',1.5);
    bar(5, CSIF_vpd, 'FaceColor',clr(2,:), 'EdgeColor',clr(2,:).^2, 'LineWidth',1.5);
    
    Tstats.dCSIF(i) = CSIF_anom;
    
    ens = mean(SRMstats.CSIF_All(idx, :));
    ci = quantile(ens, [0.025 0.975]);
    plot([1 1], [ci(1) ci(2)], '-', 'Color',clr(5,:).^2, 'LineWidth',1.5)
    Tstats.dCSIF_All(i) = sprintf('%.2f [%.2f, %.2f]', CSIF_all, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 1));
    ci = quantile(ens, [0.025 0.975]);
    plot([2 2], [ci(1) ci(2)], '-', 'Color',clr(4,:).^2, 'LineWidth',1.5)
    Tstats.dCSIF_PAR(i) = sprintf('%.2f [%.2f, %.2f]', CSIF_par, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 2));
    ci = quantile(ens, [0.025 0.975]);
    plot([3 3], [ci(1) ci(2)], '-', 'Color',clr(3,:).^2, 'LineWidth',1.5)
    Tstats.dCSIF_SM(i) = sprintf('%.2f [%.2f, %.2f]', CSIF_sm, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 3));
    ci = quantile(ens, [0.025 0.975]);
    plot([4 4], [ci(1) ci(2)], '-', 'Color',clr(1,:).^2, 'LineWidth',1.5)
    Tstats.dCSIF_Tair(i) = sprintf('%.2f [%.2f, %.2f]', CSIF_tair, ci(1), ci(2)); 
    
    ens = mean(SRMstats.BootSims(idx, :, 4));
    ci = quantile(ens, [0.025 0.975]);
    plot([5 5], [ci(1) ci(2)], '-', 'Color',clr(2,:).^2, 'LineWidth',1.5)
    Tstats.dCSIF_VPD(i) = sprintf('%.2f [%.2f, %.2f]', CSIF_vpd, ci(1), ci(2)); 
    
    hold off;
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0],...
            'XLim',[0.25 5.75], 'FontSize',7)
    if i <= 3
        set(gca,'YLim',[-0.065 0.025]);
    elseif i <=6
        set(gca,'YLim',[-0.03 0.01]);
    elseif i <=9
        set(gca,'YLim',[-0.01 0.01]);
    end
    
    ylim = get(gca, 'YLim');
    text(0.4, ylim(2), [alphabet(i),') ', sites{i}], 'VerticalAlignment','top', 'FontWeight','bold')
    text(5.6, ylim(2), ['R^{2} = ', sprintf('%.2f', mean(SRMstats.R2_Validation, 'omitnan'))],...
        'VerticalAlignment','top', 'HorizontalAlignment','right', 'FontSize',8)
    
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
        ylb = ylabel('Mean CSIF anomaly (mW m^{-2} nm^{-1} sr^{-1})', 'FontSize',10);
        ylb.Position(1) = -1;
    end
    
end

%% Save figure
set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/ameriflux-csif-attribution-models.tif')
close all;

%% Save table
writetable(Tstats, './output/ameriflux_csif_attribution.xlsx');

