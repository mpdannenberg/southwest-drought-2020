% Main file

%% Make map of climate anomalies during the 2020 drought
get_prism_climate_anomalies;

%% Get MODIS and Rangeland Analysis V2 land cover data
read_modis_lc;
read_rangeland_lc;

%% Make study area, flux tower, and ecoregion map
make_study_area_tower_ecoregion_map;

%% SMAP attribution
% Get and organize gridded datasets
get_smap_gpp_monthly_gridded;
get_smap_sm_monthly_gridded;

% RUN ON HPC: Attribute observed July-Oct GPP variation to meteorological
% variables
% model_smap_gpp_climate_attribution;

% Make maps and figures of SMAP GPP anomaly attribution
map_smap_gpp_climate_attribution_by_ecoregion;
plot_lc_gpp_climate_attribution;
plot_total_gpp_climate_attribution;

% Make supplementary figure showing model validation statistics and annual
% GPP by ecoregions
make_model_validation_map;
map_smap_gpp_average_by_ecoregion;

%% CSIF attribution
% Get and organize CSIF data
get_csif_monthly_gridded;

% RUN ON HPC: Attribute observed July-Oct CSIF variation to meteorological
% variables
% model_csif_climate_attribution;

% Make maps and figures of CSIF anomaly attribution
map_csif_gridded_climate_attribution;

%% Ameriflux attribution
% Read, process, and aggregate daily Ameriflux to monthly
read_daily_ameriflux;

% Attribute observed July-Oct GPP variation to drought variables
model_ameriflux_gpp_climate_attribution;

% Make supplementary figures showing annual Jul-Oct GPP at each site,
% attribution using SMAP GPP at each site, and sensitivity to variable
% order
plot_ameriflux_annual_gpp;
model_ameriflux_smap_climate_attribution;
test_sensitivity_variable_order;

