% Plot annual July-October GPP at the flux sites

alphabet = 'abcdefghijklmnopqrstuvwxyz';
syear = 2001;
eyear = 2020;
ndays = 31 + 31 + 30 + 31; % Total number of days (for conversion from gC m-2 day-1 to gC m-2)
yrs = syear:eyear;
nrows = 9;
ncols = 1;
clr = wesanderson('fantasticfox1');

h = figure('Color','w');
h.Units = 'inches';
h.Position = [1 1 4.5 7.5];
ax = tight_subplot(nrows, ncols, 0.02, [0.05 0.03], [0.12 0.1]);

sites = {'US-SRG','US-SRM','US-Wkg','US-Whs','US-Mpj','US-Seg','US-Wjs','US-Ses','US-Ton'};
n = length(sites);

for i = 1:n
    
    fn = glob(['./data/Ameriflux_monthly/',sites{i},'*.csv']);
    T = readtable(fn{1});
    
    GPP_total = NaN(length(yrs),1);
    for j=1:length(yrs) 
        
        gpp_temp = T.GPP(T.Year==yrs(j) & T.Month>=7 & T.Month<=10); 
        GPP_total(j) = ndays * mean(gpp_temp); 
        
    end
    
    axes(ax(i))
    
    plot(syear:eyear, GPP_total, 'k-', 'LineWidth',1.2)
    hold on;
    plot([min(T.Year(~isnan(T.GPP) & T.Month==7)) eyear], [mean(GPP_total(yrs>=2015 & yrs<=2019)) mean(GPP_total(yrs>=2015 & yrs<=2019))], 'k--')
    plot(2019:2020, GPP_total(yrs>=2019 & yrs<=2020),'-','Color', clr(2,:).^2, 'LineWidth',1.3)
    scatter(yrs, GPP_total, 30, 'k', 'filled')
    scatter(2020, GPP_total(yrs==2020), 40, clr(2,:).^2, 'filled')
    box off;
    set(gca, 'TickDir','out', 'TickLength',[0.02 0], 'XLim',[syear eyear])
    
    
    if i < n
        set(gca, 'XTickLabel','', 'XColor','w');
    end
    
    if i == median([1 n])
        yl = ylabel('July-October GPP (g C m^{-2})', 'FontSize',10);
        yl.Position(1) = yl.Position(1)-0.2;
    end
    
    ylim = get(gca,'YLim');
    set(gca, 'YLim',[0 1.2*ylim(2)]);
    if strcmp(sites{i}, 'US-Var')
        set(gca, 'YLim',[ylim(1)-0.1*range(ylim) ylim(2)+0.1*range(ylim)]);
    end
    ylim = get(gca,'YLim');
    
    text(syear+0.2, ylim(2), ['\bf',alphabet(i),')\rm ', sites{i}],...
        'FontSize',10, 'FontWeight','bold','VerticalAlignment','top')
    text(2020.4, GPP_total(yrs==2020),...
        [num2str(100*round(GPP_total(yrs==2020)/mean(GPP_total(yrs>=2015 & yrs<=2019)), 2)),'%'],...
        'HorizontalAlignment','left', 'VerticalAlignment','middle',...
        'Color',clr(2,:).^2, 'FontWeight','bold', 'FontSize',11)

end

% Save figure
set(gcf,'PaperPositionMode','auto')
print('-dtiff','-f1','-r300','./output/ameriflux-annual-gpp.tif')
close all;
