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
map_smap_gpp_anomaly_by_ecoregion;
plot_ecoregion_lc_gpp_climate_attribution;
plot_total_gpp_climate_attribution;

% Make supplementary figure showing model validation statistics and annual
% GPP by ecoregions
make_model_validation_map;

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

%% Supplementary figures
% Make supplementary figures showing annual Jul-Oct GPP at each site,
% attribution using SMAP GPP/CSIF at each site, sensitivity to variable
% order, and comparison of SMAP and tower anomalies
plot_ameriflux_annual_gpp;
plot_lc_annual_gpp;
model_ameriflux_smap_climate_attribution;
model_ameriflux_csif_climate_attribution;
test_sensitivity_variable_order;
compare_ameriflux_smap_gpp;
map_smap_gridded_gpp_climate_attribution;

