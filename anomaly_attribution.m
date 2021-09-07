function [T, stats] = anomaly_attribution(y,X,varargin)
%Attribute anomalies in y (e.g., GPP) to anomalies in X (e.g., climate)
%   y: response variable (12 x years)
%   X: predictor variables (12 x years x n), where n is number of variables

[nmos, nyrs, nvars] = size(X);

% Optional inputs and defaults
if nargin > 2 % read in advanced options if user-specified:
    % first fill values in with defaults:
    nlags = 0; % Number of predictor lags to use
    npcs = 0.95; % Variance threshold for PCs (if <1) or number of PCs to use (if integer)... OR simple model (no transformation) if zero (TBD)
    method = 'fitlm'; % regression approach
    modelspec = 'linear'; % terms to include in model
    yname = 'y'; % Name of response variable
    xnames = strcat('X',cellstr(num2str([1:nvars]'))'); % Names of X variables
    nsims = 0; % Number of bootstrap simulations to use for model uncertainty
    trainset = true(size(y)); % observations to use for training the model
    baseyrs = true(1,nyrs); % years to use for baseline
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
            case 'method'
                method = valin;
            case 'modelspec'
                modelspec = valin;
            case 'yname'
                yname = valin;
            case 'xnames'
                xnames = valin;
            case 'nsims'
                nsims = valin;
            case 'trainset'
                trainset = valin;
            case 'baseyrs'
                baseyrs = valin;
        end
    end
else % otherwise, read in defaults:
    nlags = 0;
    npcs = 0.95;
    method = 'fitlm'; 
    modelspec = 'linear';
    yname = 'y';
    strcat('X',cellstr(num2str([1:nvars]'))');
    nsims = 0;
    trainset = true(size(y));
    baseyrs = true(1,nyrs); 
end

% Deseasonalize response variable
ybar = repmat(nanmean(y(:,baseyrs), 2), 1, nyrs);
y = (y - ybar);
ybar = reshape(ybar, [], 1);
y = reshape(y, [], 1);
trainset = reshape(trainset, [], 1);

% Deseasonalize predictor variables
Xbar = repmat(nanmean(X(:,baseyrs,:), 2), 1, nyrs, 1);
Xstd = repmat(nanstd(X(:,baseyrs,:), 0, 2), 1, nyrs, 1);
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
if strcmp(method, 'fitlm')
    mdl_full = fitlm(Xpcs(trainset,:), y(trainset), modelspec); 
elseif strcmp(method, 'stepwiselm')
    mdl_full = stepwiselm(Xpcs(trainset,:), y(trainset), modelspec, 'Criterion','bic', 'Verbose',0); 
else
    disp('"method" not recognized');
    return
end
stats.Model = mdl_full;
y_full = predict(mdl_full, Xpcs); y_full(~trainset) = NaN;

% Bootstrapped models
if nsims > 0
    r2_cal = NaN(nsims, 1); 
    r2_val = NaN(nsims, 1); 
    mdl_ens = cell(nsims, 1);
    Yall = NaN(nmos*nyrs, nsims);
    nm = sum(trainset);
    ysub = y(trainset);
    Xsub = Xpcs(trainset,:);
    for i = 1:nsims
        [Xsamp, idx] = datasample(Xsub, nm, 1); % sample data with replacement
        [~,ia] = setdiff(1:nm, idx); % find observations that were not sampled

        mdl = fitlm(Xsamp, ysub(idx), ['y ~ ',mdl_full.Formula.LinearPredictor]);

        yhat = predict(mdl, Xsub(ia,:));
        r2_val(i) = corr(ysub(ia), yhat, 'rows','pairwise')^2;
        r2_cal(i) = mdl.Rsquared.Ordinary;
        mdl_ens{i} = mdl;
        Yall(:,i) = predict(mdl, Xpcs);
    end
    
    stats.ModelEnsemble = mdl_ens;
    stats.R2_Calibration = r2_cal;
    stats.R2_Validation = r2_val;
    
end

% Initialize scenario (all climate variables set at their mean)
Xtemp = zeros(size(X));
Xtemp(isnan(X)) = NaN;
Xpcs = Xtemp * coeffs;
y0 = predict(mdl_full, Xpcs(:,1:n));

% Initialize table with observed and fitted values
T = table(y + ybar, ybar, y_full + ybar - y0, ...
    'VariableNames',{strcat(yname,'_Obs'),strcat(yname,'_Avg'),strcat(yname,'_All')});

% Run scenario differencing
for i = 1:nvars
    Xtemp(:, i:nvars:((nlags+1)*nvars)) = X(:, i:nvars:((nlags+1)*nvars));
    Xpcs = Xtemp * coeffs;
    yhat = predict(mdl_full, Xpcs(:,1:n)); yhat(~trainset) = NaN;
    T.(strcat(yname,'_',xnames{i})) = (yhat - y0) + ybar;
    y0 = yhat;
end

% Bootstrapped CIs on anomaly attribution
if nsims > 0
    stats.BootSims = NaN(nmos*nyrs, nsims, nvars);
    Xtemp = zeros(size(X));
    Xtemp(isnan(X)) = NaN;
    Xpcs = Xtemp * coeffs;
    y0 = zeros(size(ybar,1), nsims);
    % Initialize scenario (all climate variables set at their mean)
    for j = 1:nsims
        y0(:, j) = predict(stats.ModelEnsemble{j}, Xpcs(:,1:n));
    end
    eval(['stats.',yname,'_All = Yall - y0;']);
    % Change one variable at a time and simulate with the model ensemble
    for i = 1:nvars
        Xtemp(:, i:nvars:((nlags+1)*nvars)) = X(:, i:nvars:((nlags+1)*nvars));
        Xpcs = Xtemp * coeffs;
        for j = 1:nsims
            yhat = predict(stats.ModelEnsemble{j}, Xpcs(:,1:n)); yhat(~trainset) = NaN;
            stats.BootSims(:, j, i) = yhat - y0(:, j);
            y0(:, j) = yhat;
        end
    end
end

end

