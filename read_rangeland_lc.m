% Read Rangeland Analysis land cover 
load ./data/SMAP_L4C_GPP_monthly.mat;

ag = multibandread('./data/Rangeland_VegetationCover/Grass_AFGC.bil', [233 268 1], 'float32', 0, 'bsq','ieee-le');
pg = multibandread('./data/Rangeland_VegetationCover/Grass_PFGC.bil', [233 268 1], 'float32', 0, 'bsq','ieee-le');
sh = multibandread('./data/Rangeland_VegetationCover/Shrub.bil', [233 268 1], 'float32', 0, 'bsq','ieee-le');
tr = multibandread('./data/Rangeland_VegetationCover/Tree.bil', [233 268 1], 'float32', 0, 'bsq','ieee-le');

rangeland = zeros(size(tr));
rangeland(sh >= 10) = 2;
rangeland(tr >= 30) = 1;
rangeland(tr >= 10 & tr < 30) = 3;
rangeland(sh < 10 & tr < 10 & (pg+ag) > 20 & ag >= pg) = 4;
rangeland(sh < 10 & tr < 10 & (pg+ag) > 20 & ag < pg) = 5;

clear ag pg sh tr;

%% Get croplands from MODIS LC
load ./data/mcd12c1;
rangeland(biome==5 & repmat(lon',length(lat),1) <= -110 & repmat(lat,1,length(lon))>42) = 6;
rangeland(biome==5 & repmat(lon',length(lat),1) <= -110 & repmat(lat,1,length(lon))<=42) = 7;
rangeland(biome==5 & repmat(lon',length(lat),1) > -110) = 8;
rangeland(biome==0) = NaN;

save('./data/rangeland.mat', 'rangeland');

