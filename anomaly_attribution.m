function [T, stats] = anomaly_attribution(y,X,varargin)
%Attribute anomalies in y (e.g., GPP) to anomalies in X (e.g., climate)
%   y: response variable (12 x years)
%   X: predictor variables (12 x years x n), where n is number of variables

[nmos, nyrs, nvars] = size(X);

% Optional inputs and defaults
if nargin > 2 % read in advanced options if user-specified:
    % first fill values in with defaults:
    nlags = 0; % Number of predictor lags to use
    npcs = 0.95; % Variance threshold for PCs (if <1) or number of PCs to use (if integer)
    yname = 'y'; % Name of response variable
    xnames = strcat('X',cellstr(num2str([1:nvars]'))'); % Names of X variables
    nsims = 0; % Number of bootstrap simulations to use for model uncertainty
    % then over-write defaults if user-specified:
    Nvararg = length(varargin);
    for i = 1:Nvararg/2
        namein = varargin{2*(i-1)+1};
        valin = varargin{2*i};
        switch namein
            case 'nlags'
                nlags = valin;
            case 'npcs'
                npcs = valin;
            case 'yname'
                yname = valin;
            case 'xnames'
                xnames = valin;
            case 'nsims'
                nsims = valin;
        end
    end
else % otherwise, read in defaults:
    nlags = 0;
    npcs = 0.95;
    yname = 'y';
    strcat('X',cellstr(num2str([1:nvars]'))');
    nsims = 0;
end

% Deseasonalize response variable
ybar = repmat(nanmean(y, 2), 1, nyrs);
ystd = repmat(nanstd(y, 0, 2), 1, nyrs);
%y = (y - ybar) ./ ystd;
y = (y - ybar);
ybar = reshape(ybar, [], 1);
%ystd = reshape(ystd, [], 1);
y = reshape(y, [], 1);

% Deseasonalize predictor variables
Xbar = repmat(nanmean(X, 2), 1, nyrs, 1);
Xstd = repmat(nanstd(X, 0, 2), 1, nyrs, 1);
X = (X - Xbar) ./ Xstd;
X = reshape(permute(X, [3 1 2]), nvars, [])';

% Add lags to X matrix
if nlags > 0
    Xtemp = X;
    for i = 1:nlags
        
        Xlags = lagmatrix(X, i);
        Xtemp = [Xtemp Xlags];
        
    end
    X = Xtemp;
end

% Get PCs of X matrix
[coeffs,Xpcs,~,~,vexp] = pca(X, 'Centered','off');
if npcs < 1
    n = max(find(cumsum(vexp)/100 <= npcs)) + 1;
elseif rem(npcs, 1)==0
    n = npcs;
else
    disp('"npcs" is not an integer... rounding to nearest whole number');
    n = round(npcs);
end
Xpcs = Xpcs(:, 1:n);

% Fit main model
mdl_full = fitlm(Xpcs, y); 

% Bootstrapped models
if nsims > 0
    r2_cal = NaN(nsims, 1); 
    r2_val = NaN(nsims, 1); 
    mdl_ens = cell(nsims, 1);
    nm = nmos * nyrs;
    for i = 1:nsims
        [Xsub, idx] = datasample(Xpcs, nm, 1); % sample data with replacement
        [~,ia] = setdiff(1:nm, idx); % find observations that were not sampled

        mdl = fitlm(Xsub, y(idx));
        yhat = predict(mdl, Xpcs(ia,:));
        r2_val(i) = corr(y(ia), yhat, 'rows','pairwise')^2;
        r2_cal(i) = mdl.Rsquared.Ordinary;
        mdl_ens{i} = mdl;
    end
    
    stats.ModelEnsemble = mdl_ens;
    stats.R2_Calibration = r2_cal;
    stats.R2_Validation = r2_val;
end

% Initialize table with observed and fitted values
% T = table(y .* ystd + ybar,...
%     ybar,...
%     mdl_full.Fitted .* ystd + ybar,...
%     'VariableNames',{strcat(yname,'_Obs'),strcat(yname,'_Avg'),strcat(yname,'_All')});
T = table(y + ybar, ybar, mdl_full.Fitted + ybar, ...
    'VariableNames',{strcat(yname,'_Obs'),strcat(yname,'_Avg'),strcat(yname,'_All')});

% Scenario differencing
Xtemp = zeros(size(X));
Xtemp(isnan(X)) = NaN;
y0 = zeros(size(ybar));
for i = 1:nvars
%     Xtemp = zeros(size(X));
%     Xtemp(isnan(X)) = NaN;
    Xtemp(:, i:nvars:((nlags+1)*nvars)) = X(:, i:nvars:((nlags+1)*nvars));
%     Xtemp = X;
%     Xtemp(:, i:nvars:((nlags+1)*nvars)) = 0;
%     Xtemp(isnan(X)) = NaN;
    Xpcs = Xtemp * coeffs;
    yhat = predict(mdl_full, Xpcs(:,1:n));
    %T.(strcat(yname,'_',xnames{i})) = yhat .* ystd + ybar;
    %T.(strcat(yname,'_',xnames{i})) = (mdl_full.Fitted - yhat) + ybar;
    T.(strcat(yname,'_',xnames{i})) = (yhat - y0) + ybar;
    y0 = yhat;
    
end

end

