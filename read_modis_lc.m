% Read MODIS land cover and CRU temperature and convert to Ahlstrom 2015
% classes

%% MCD12C1, aggregated to three classes (forest, savanna/shrub, grass/crop)
mcd12c1_lat = (90-0.025):-0.05:(-90+0.025);
mcd12c1_lon = (-180+0.025):0.05:(180-0.025);

cd('D:\Data_Analysis\MCD12C1_v006');
%fns = glob('*.hdf');
fns = 'MCD12C1.A%d001.*.hdf';
yrs = 2015:2019;
mcd12c1 = NaN(length(mcd12c1_lat), length(mcd12c1_lon), length(yrs));
for i = 1:length(yrs)
    fn = glob(sprintf(fns, yrs(i)));
    mcd12c1(:,:,i) = double(hdfread(fn{1}, 'Majority_Land_Cover_Type_2'));
end
clear i fns fn yrs;
mcd12c1 = mode(mcd12c1, 3);

%% Nearest neighbor resampling
cd('D:\Publications\Dannenberg_et_al_SouthwestDrought2020');
load ./data/SMAP_L4C_GPP_monthly.mat;

igbp = NaN(length(lat), length(lon));
for i = 1:length(lat)
    for j = 1:length(lon)
        
        dlat = abs(lat(i) - mcd12c1_lat);
        dlon = abs(lon(j) - mcd12c1_lon);
        
        latidx = find(dlat == min(dlat));
        lonidx = find(dlon == min(dlon));
        
        igbp(i, j) = mcd12c1(latidx(1), lonidx(1));
        
    end
end
biome = zeros(size(igbp));
biome(igbp >= 1 & igbp <= 5) = 1; % Forest
biome(igbp >= 6 & igbp <= 7) = 2; % Shrub
biome(igbp >= 8 & igbp <= 9) = 3; % Savanna
biome(igbp == 10) = 4; % Grass 
biome(igbp == 12 | igbp == 14) = 5; % Crop 
biome(biome==0) = NaN;

save('./data/mcd12c1.mat', 'biome','igbp');

