% Read in daily fluxes and estimate monthly

fns = glob('./data/Ameriflux_daily/*.csv');
n = length(fns);
nVars = 18;
varTypes = cell(1, nVars); varTypes(:) = {'double'};
varNames = {'Year','Month','NEE','GPP','Reco','LE','H','SW_IN','TA',...
    'Tmin','RH','VPD','VPDmax','P','SWC_5cm','SWC_10_15cm','SWC_30cm','SWC_root'};
sampThresh = 0.75;

for i = 1:n
    opts = detectImportOptions(fns{i});
    opts = setvaropts(opts, 'TreatAsMissing',{'''NA'''});
    opts = setvartype(opts, 'double');
    T = readtable(fns{i}, opts);
    T(:,1) = [];
    
    site = strsplit(fns{i},'_');
    site = site{3};
    
    [yr,mo,dy] = datevec(datenum(T.Year,1,1) + T.DoY - 1);
    uyr = yr(1):yr(end);
    
    Tmonthly = table('Size',[length(uyr)*12 nVars], 'VariableTypes',varTypes,...
        'VariableNames',varNames);
    Tmonthly{:,:} = NaN;
    
    idx=1;
    for y = uyr
        for m = 1:12
            
            Tsub = T(yr==y & mo==m, :);
            
            Tmonthly.Year(idx) = y;
            Tmonthly.Month(idx) = m;
            
            % NEE
            w = 1 - Tsub.NEE_fqc/3;
            nm = ~isnan(Tsub.NEE_f);
            Tmonthly.NEE(idx) = sum(Tsub.NEE_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm); Tmonthly.NEE(idx) = NaN; end
            
            % GPP
            w = 1 - Tsub.GPP_fqc/3;
            nm = ~isnan(Tsub.GPP_f);
            Tmonthly.GPP(idx) = sum(Tsub.GPP_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm); Tmonthly.GPP(idx) = NaN; end
            
            % Reco
            w = 1 - Tsub.NEE_fqc/3;
            nm = ~isnan(Tsub.Reco_f);
            Tmonthly.Reco(idx) = sum(Tsub.Reco_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm); Tmonthly.Reco(idx) = NaN; end
            
            % LE
            w = 1 - Tsub.LE_fqc/3;
            nm = ~isnan(Tsub.LE_f);
            Tmonthly.LE(idx) = sum(Tsub.LE_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm); Tmonthly.LE(idx) = NaN; end
            
            % H
            w = 1 - Tsub.H_fqc/3;
            nm = ~isnan(Tsub.H_f);
            Tmonthly.H(idx) = sum(Tsub.H_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm); Tmonthly.H(idx) = NaN; end
            
            % SW_IN
            w = 1 - Tsub.Rg_fqc/3;
            nm = ~isnan(Tsub.Rg_f);
            Tmonthly.SW_IN(idx) = sum(Tsub.Rg_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm); Tmonthly.SW_IN(idx) = NaN; end
            
            % TA & Tmin
            w = 1 - Tsub.Tair_fqc/3;
            nm = ~isnan(Tsub.Tair_f);
            Tmonthly.TA(idx) = sum(Tsub.Tair_f(nm) .* w(nm)) ./ sum(w(nm));
            Tmonthly.Tmin(idx) = sum(Tsub.Tmin_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm)
                Tmonthly.TA(idx) = NaN; 
                Tmonthly.Tmin(idx) = NaN;
            end
            
            % RH
            nm = ~isnan(Tsub.rH);
            Tmonthly.RH(idx) = nanmean(Tsub.rH);
            if sum(nm) < sampThresh*length(nm); Tmonthly.RH(idx) = NaN; end
            
            % VPD & VPDmax
            w = 1 - Tsub.VPD_fqc/3;
            nm = ~isnan(Tsub.VPD_f);
            Tmonthly.VPD(idx) = sum(Tsub.VPD_f(nm) .* w(nm)) ./ sum(w(nm));
            Tmonthly.VPDmax(idx) = sum(Tsub.VPDmax_f(nm) .* w(nm)) ./ sum(w(nm));
            if sum(nm) < sampThresh*length(nm)
                Tmonthly.VPD(idx) = NaN; 
                Tmonthly.VPDmax(idx) = NaN; 
            end
            
            % P
            nm = ~isnan(Tsub.P);
            Tmonthly.P(idx) = nansum(Tsub.P);
            if sum(nm) < length(nm); Tmonthly.P(idx) = NaN; end
            
            % SWC (5cm)
            nm = ~isnan(Tsub.SWC_5cm);
            Tmonthly.SWC_5cm(idx) = nanmean(Tsub.SWC_5cm);
            if sum(nm) < sampThresh*length(nm); Tmonthly.SWC_5cm(idx) = NaN; end
            
            % SWC (10/15 cm)
            nm = ~isnan(Tsub.SWC_10cm);
            Tmonthly.SWC_10_15cm(idx) = nanmean(Tsub.SWC_10cm);
            if sum(nm) < sampThresh*length(nm); Tmonthly.SWC_10_15cm(idx) = NaN; end
            
            % SWC (30cm)
            nm = ~isnan(Tsub.SWC_30cm);
            Tmonthly.SWC_30cm(idx) = nanmean(Tsub.SWC_30cm);
            if sum(nm) < sampThresh*length(nm); Tmonthly.SWC_30cm(idx) = NaN; end
            
            % SWC (0-30cm)
            nm = ~isnan(Tsub.SWC_root);
            Tmonthly.SWC_root(idx) = nanmean(Tsub.SWC_root);
            if sum(nm) < sampThresh*length(nm); Tmonthly.SWC_root(idx) = NaN; end
            
            idx = idx+1;
        end
    end
    
    writetable(Tmonthly, ['./data/Ameriflux_monthly/',site,'_monthly.csv']);
    
end


