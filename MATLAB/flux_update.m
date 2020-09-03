% Script to plot updates to observed freshwater flux and storage timeseries
% Sep '16, Aug '20
% twnh

%% Housekeeping
close all
clear
more off
fprintf(1,'\n Freshwater flux update. \n Uses Haine et al. (2015) flux numbers, plus available updates.\n This version makes a figure for diagnostic purposes and writes out a data file for use by schematic_figure.m.\n Sep ''16, Aug ''20.\n\n') ;

% Parameters
params.Sice   = 4 ;         % sea ice salinity g/kg
params.rhoice = 900 ;       % sea ice density kg/m^3
params.Sref   = 34.8 ;      % Reference salinity g/kg

%% Load original data from Haine et al. (2015).
original_flux_data = load_Hetal15_flux_data('../data/original_data/') ;
flux_data          = original_flux_data ;

%% Bering Strait: Rebecca data update (the entire time series):
new_data = load_process_Rebecca_data ;
flux_data.BeringStrait.liquid_time = new_data.time ;
flux_data.BeringStrait.liquid_flux = new_data.liquid_flux ;
flux_data.BeringStrait = rmfield(flux_data.BeringStrait,{'time','total_flux'}) ;

subplot(6,1,1)
hold on
grid on
plot(original_flux_data.BeringStrait.time,original_flux_data.BeringStrait.total_flux,'bo-')
plot(flux_data.BeringStrait.liquid_time,flux_data.BeringStrait.liquid_flux,'g*-')
ylabel('km^3yr^{-1}')
title('Bering Strait')
legend('Haine et al. (2015)','Updated data')

%% Davis Strait: Beth data
new_data = load_process_Beth_data ;
flux_data.DavisStrait.liquid_time = new_data.liquid_time;
flux_data.DavisStrait.solid_time  = new_data.liquid_time ;
flux_data.DavisStrait.liquid_flux = new_data.liquid_flux ;
flux_data.DavisStrait.solid_flux  = new_data.solid_flux ;
flux_data.DavisStrait             = rmfield(flux_data.DavisStrait,'time') ;

% Plot Davis Strait
subplot(6,1,2)
hold on
grid on
plot(original_flux_data.DavisStrait.time,original_flux_data.DavisStrait.liquid_flux,'bo-')
plot(flux_data.DavisStrait.liquid_time,flux_data.DavisStrait.liquid_flux,'g*-')
ylabel('km^3yr^{-1}')
title('Davis Strait')

%% Fram Strait: ice flux from Gunnar
% Read Gunnar's Fram Strait ice volume data from: https://data.npolar.no/dataset/696b80db-60bf-4d07-8d1a-f3dbbd376494
filename = '../data/From Gunnar/Fram Strait Sea Ice Volume Flux - ULS thickness + JPL ice drift - 1992-2014.csv' ;
new_data = load_process_Gunnar_data(filename,params) ;

% Add Gunnar's latest solid data to overwrite the
% corresponding times in the original data:
inds = (flux_data.FramStrait.time > min(new_data.time)) ;
flux_data.FramStrait.time(inds)       = [] ;
flux_data.FramStrait.solid_flux(inds) = [] ;
flux_data.FramStrait.solid_time       = [flux_data.FramStrait.time;       new_data.time] ;
flux_data.FramStrait.solid_flux       = [flux_data.FramStrait.solid_flux; new_data.solid_flux] ;

% Plot
subplot(6,1,3)
grid on
hold on
plot(original_flux_data.FramStrait.time,original_flux_data.FramStrait.solid_flux,'bo-')
plot(flux_data.FramStrait.solid_time,flux_data.FramStrait.solid_flux,'g*-')
ylabel('km^3yr^{-1}')
title('Fram Strait solid')

%% Fram Strait: liquid flux from Laura
% Data from: https://data.npolar.no/dataset/9e01a801-cddf-4f2d-8ed5-b367ad73ea41
filenames = {'../data/From Laura/Fram_Strait_freshwater_transport_1997-2002-v2.0.nc',...
             '../data/From Laura/Fram_Strait_freshwater_transport_2002-2015-v2.0.nc'} ;
new_data = load_process_Laura_data(filenames) ;
flux_data.FramStrait.liquid_time = new_data.time ;
flux_data.FramStrait.liquid_flux = new_data.liquid_flux ;
flux_data.FramStrait = rmfield(flux_data.FramStrait,'time') ;

% Plot
subplot(6,1,4)
grid on
hold on
plot(original_flux_data.FramStrait.time,original_flux_data.FramStrait.liquid_flux,'bo-')
plot(flux_data.FramStrait.liquid_time,flux_data.FramStrait.liquid_flux,'g*-')
ylabel('km^3yr^{-1}')
title('Fram Strait liquid')

%% LFC timeseries from flux convergence: This timeseries is the same as Hetal15. This is not exactly consistent with the updated timeseries above. This needs to be fixed.
load('../data/original_data/observed_flux_model') ;       % LFC volume from flux convergence, including the lfc volume increment due to PIOMAS ice loss.
flux_data.liquid_Storage.time   = times1b ;
flux_data.liquid_Storage.volume = volumes1b ;

% Plot
subplot(6,1,5)
grid on
hold on
plot(flux_data.liquid_Storage.time,flux_data.liquid_Storage.volume,'bo-') ;
ylabel('km^3')
title('Freshwater storage liquid')

%% PIOMAS sea ice timeseries from Jinlun
filename = '../data/From Jinlun/PIOMAS.vol.daily.1979.2020.Current.v2.1.dat' ;
new_data = load_process_Jinlun_data(filename,params) ;
flux_data.solid_Storage.time   = new_data.time ;
flux_data.solid_Storage.volume = new_data.volume ;

% Plot
subplot(6,1,6)
grid on
hold on
plot(flux_data.solid_Storage.time,flux_data.solid_Storage.volume,'g*-') ;
ylabel('km^3')
title('Freshwater storage solid')

%% Save updated data files
filename = '../data/updated_data/flux_data' ;
save(filename,'flux_data') ;
fprintf(1,'\n Updated data saved to [%s].\n\n',filename) ;

%% Local functions
function flux_data = load_Hetal15_flux_data(directory)
% Load data files from Haine et al. (2015).

fprintf(1,' Loading data files from Haine et al. (2015)...') ;
this_dir = pwd ;
cd(directory)
load('ERA_INTERIM_PmE_data.mat','ERA_INTERIM_PmE_data') ;
flux_data.ERAI_PmE.time            = ERA_INTERIM_PmE_data(1,:)' ;
flux_data.ERAI_PmE.flux            = ERA_INTERIM_PmE_data(2,:)' ;
load('ERA_INTERIM_runoff_data.mat','ERA_INTERIM_runoff_data') ;
flux_data.ERAI_runoff.time         = ERA_INTERIM_runoff_data(1,:)' ;
flux_data.ERAI_runoff.flux         = ERA_INTERIM_runoff_data(2,:)' ;
load('Shiklomanov_runoff_data.mat','Shiklomanov_runoff_data') ;
flux_data.Shiklomanov_runoff.time  = Shiklomanov_runoff_data(1,:)' ;
flux_data.Shiklomanov_runoff.flux  = Shiklomanov_runoff_data(2,:)' ;
load('BStr_flux_data.mat','BStr_flux_data') ;
flux_data.BeringStrait.time        = BStr_flux_data(1,:)' ;
flux_data.BeringStrait.total_flux  = BStr_flux_data(2,:)' ;
load('FrStr_Lflux_data.mat','FrStr_Lflux_data') ;
flux_data.FramStrait.time          = FrStr_Lflux_data(1,:)' ;
flux_data.FramStrait.liquid_flux   = FrStr_Lflux_data(2,:)' ;
load('FrStr_iceflux_data.mat','FrStr_iceflux_data') ;
flux_data.FramStrait.solid_flux    = FrStr_iceflux_data(2,:)' ;
load('CAA_flux_data.mat','CAA_flux_data') ;
flux_data.DavisStrait.time         = CAA_flux_data(1,:)' ;
flux_data.DavisStrait.liquid_flux  = CAA_flux_data(2,:)' ;
cd(this_dir) ;
fprintf(1,'done.\n') ;

end

function data = load_process_Rebecca_data

% From: BeringStrait_Annualmeans_FW_Jun2017.txt in Rebecca email of
% 28Aug20. Her txt file is hard to read directly.
fprintf(1,' Loading Bering Strait data from Rebecca 28Aug20...') ;
in_data = [
      1991         2529         2729   ;...
      1992          NaN          NaN   ;...
      1993          NaN          NaN   ;...
      1994          NaN          NaN   ;...
      1995          NaN          NaN   ;...
      1996          NaN          NaN   ;...
      1997          NaN          NaN   ;...
      1998          NaN          NaN   ;...
      1999          NaN          NaN   ;...
      2000         2554         2754   ;...
      2001         2259         2459   ;...
      2002         2592         2792   ;...
      2003         2964         3164   ;...
      2004         3080         3280   ;...
      2005         2367         2567   ;...
      2006         2603         2803   ;...
      2007         3026         3226   ;...
      2008         2530         2730   ;...
      2009         2732         2932   ;...
      2010         3070         3270   ;...
      2011         3152         3352   ;...
      2012         2352         2552   ;...
      2013         3127         3327   ;...
      2014         3329         3529   ;...
      2015         3170         3370   ;...
      2016          NaN          NaN   ] ;

data.time        = in_data(:,1)+0.5 ;
data.liquid_flux = nanmean(in_data(:,2:3),2) ;
fprintf(1,'done.\n') ;

end

function new_data = load_process_Beth_data

fprintf(1,' Loading Davis Strait data from Beth Sep16...') ;

% From September 2016 email.
% October 2004-September 2013
% Net Freshwater transports +- error (mSv)
DavisStr_data = [
    2004	-102	20 ; ...
    2005	-99		17 ; ...
    2006	-88		32 ; ...
    2007	-68		18 ; ...
    2008	-112	17 ; ...
    2009	-93		20 ; ...
    2010	-79		17 ; ...
    2011	-104	13 ; ...
    2012	-103	20 ] ;

% See flux_synthesis.m for origin of 1.2479 timeshift (to do with deployment periods). 31.7 converts mSv to km^3/yr
DavisStr_time = DavisStr_data(:,1)+1.2479 ;
DavisStr_data = DavisStr_data(:,2).*31.7 ;

% From make_flux_synthesis.m. These numbers are much less reliable.
%old_DavisStr_data = [
%    1987      -3730	1104     NaN ;
%    1988      -4618	915      NaN ;
%    1989      -5067	1041     NaN ] ;
%old_DavisStr_data(:,1) = old_DavisStr_data(:,1)+1.1658 ;
% Include old data:
%new_data.liquid_time = [old_DavisStr_data(:,1); DavisStr_time] ;
%new_data.liquid_flux = [old_DavisStr_data(:,2); DavisStr_data] ;

% Exclude old data:
new_data.liquid_time = DavisStr_time ;
new_data.liquid_flux = DavisStr_data ;

% Freshwater as ice flux estimates from Beth (6Aug13).
CAA_I_flx = - [
    202 ;
    268 ;
    342 ;
    346 ;
    442 ;
    284 ] ;
new_data.solid_time = (2004:2009)+1.2479 ;
new_data.solid_flux = CAA_I_flx ;
fprintf(1,'done.\n') ;

end

function data = load_process_Gunnar_data(filename,params)
% Load Gunnar's sea ice data

fprintf(1,' Loading Fram Strait sea ice data from Gunnar 27Aug20...') ;

delimiter = ';';
startRow = 2;
formatSpec = '%s%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
MonthlySeaIceVolumeExport_date = dataArray{:, 1};
MonthlySeaIceVolumeExport_flux = dataArray{:, 5};

%% Convert ice volume flux to equivalent freshwater flux at 0degC:
MonthlySeaIceVolumeExport_flux = MonthlySeaIceVolumeExport_flux*(1-params.Sice/params.Sref)*(params.rhoice/gsw_rho(params.Sice,0,0)) ;
monthly_times = 1992+1/24:1/12:2014-1/24 ;
annual_times  = 1992.5:1:2013.5 ;

% Fiddle with the data
MonthlySeaIceVolumeExport_date = cell2mat(MonthlySeaIceVolumeExport_date) ;
MonthlySeaIceVolumeExport_flux = MonthlySeaIceVolumeExport_flux*12 ; % To give km^3/yr -ve equatorward.

% Need to insert NaN for missing data.
FrStrIceVolFlx = NaN(length(monthly_times),1) ;
for mon = 1:length(monthly_times)
    this_yr  = floor(monthly_times(mon)) ;
    this_mon = floor((monthly_times(mon)-this_yr)*12) + 1 ;
    datestr = [num2str(this_yr),'/',num2str(this_mon)] ;
    if(length(datestr) == 6)
        datestr = ['0',datestr] ;
    end %if
    ind = find(MonthlySeaIceVolumeExport_date(:,1) == datestr(1) & ...
               MonthlySeaIceVolumeExport_date(:,2) == datestr(2) & ...
               MonthlySeaIceVolumeExport_date(:,3) == datestr(3) & ...
               MonthlySeaIceVolumeExport_date(:,4) == datestr(4) & ...
               MonthlySeaIceVolumeExport_date(:,5) == datestr(5) & ...
               MonthlySeaIceVolumeExport_date(:,6) == datestr(6) & ...
               MonthlySeaIceVolumeExport_date(:,7) == datestr(7) ) ;
    if(~isempty(ind))
        FrStrIceVolFlx(mon) = MonthlySeaIceVolumeExport_flux(ind) ;
    end % if
end % mon

% Build annual averages
for mon = 1:12
    datestr = num2str(mon) ;
    if(length(datestr) == 1)
        datestr = ['0',datestr] ;
    end %if
    inds = find(MonthlySeaIceVolumeExport_date(:,6) == datestr(1) & ...
        MonthlySeaIceVolumeExport_date(:,7) == datestr(2)) ;
    FrStrIceVolFlx_avg_seasonal(mon) = nanmean(MonthlySeaIceVolumeExport_flux(inds)) ;
end % if

% Fill in missing data with average seasonal cycle
FrStrIceVolFlx_filled = FrStrIceVolFlx ;
inds = find(isnan(FrStrIceVolFlx)) ;
for ii = 1:length(inds)
    this_yr  = floor(monthly_times(inds(ii))) ;
    this_mon = floor((monthly_times(inds(ii))-this_yr)*12) + 1 ;
    FrStrIceVolFlx_filled(inds(ii)) = FrStrIceVolFlx_avg_seasonal(this_mon) ;
end % ii

% Now compute filled annual average
for ii = 1:length(annual_times)
    this_yr = floor(annual_times(ii)) ;
    inds    = find(floor(monthly_times) == this_yr) ;
    FrStrIceVolFlx_ann_avg(ii) = nanmean(FrStrIceVolFlx_filled(inds)) ;
    inds2 = find(isnan(FrStrIceVolFlx(inds))) ;
end % yr

data.time       = annual_times' ;
data.solid_flux = FrStrIceVolFlx_ann_avg' ;
fprintf(1,'done.\n') ;

end

function out_data = load_process_Laura_data(filenames)
% Load and process Laura Fram Strait liquid data

fprintf(1,' Loading Fram Strait liquid data from Laura 28Aug20...') ;
out_data.time        = [] ;
out_data.liquid_flux = [] ;
for ff = 1:length(filenames)
    filename = filenames{ff} ;
    raw_data.time = double(ncread(filename,'TIME')) ;           % days since 1950-01-01T00:00:00Z
    raw_data.FWT  = double(ncread(filename,'FWT')) ;            % freshwater transport relative to Sref=34.9 in mSv
    
    raw_data.time = datetime(raw_data.time+datenum(1950,1,1,0,0,0),'ConvertFrom','datenum') ;
    raw_data.FWT  = raw_data.FWT.*(904/943).*31.7 ;             % Correction to Sref = 34.8 based on desteur et al. 2009 Table 1 and km^3/yr (31.7).
    raw_data.FWT  = raw_data.FWT - 807 - 760 ;                  % Add constant offset of 807 km^3/yr for the shelf component (unobserved). De Steur et al. And add 760km^3/yr for West Spitzbergen Current (from Serreze et al. 2006).
    
    % Compute annual averages.
    new_data(ff).time = [year(min(raw_data.time))+0.5:1:year(max(raw_data.time))]' ;
    for yr = 1:length(new_data(ff).time)
        new_data(ff).liquid_flux(yr) = nanmean(raw_data.FWT(year(raw_data.time) == new_data(ff).time(yr)-0.5)) ;
    end % yr

    % Build output.
    out_data.time        = [out_data.time;        new_data(ff).time] ;
    out_data.liquid_flux = [out_data.liquid_flux; new_data(ff).liquid_flux'] ;
    
end % ff
fprintf(1,'done.\n') ;

end

function out_data = load_process_Jinlun_data(filename,params)
% Load and process Jinlun PIOMAS sea ice extent data.
% Data from: http://psc.apl.washington.edu/wordpress/research/projects/arctic-sea-ice-volume-anomaly/data/
fprintf(1,' Loading PIOMAS sea ice data from Jinlun Aug20...') ;

%% Initialize variables.
fprintf(1,' Reading [%s]...',filename) ;
startRow = 2;

%% Format string for each line of text:
formatSpec = '%4f%4f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
Year = dataArray{:, 1};
Day  = dataArray{:, 2};
yVol = dataArray{:, 3};

%% Convert ice volume flux to equivalent freshwater flux at 0degC:
yVol = yVol*(1 - params.Sice/params.Sref)*(params.rhoice/gsw_rho(params.Sice,0,0)) ;

%% Compute annual averages.
times = Year + Day./365.25 ;
ann_mean_vol = [] ;
ann_mean_yr  = [] ;
start_yr = 1979 ;
end_yr   = max(Year)-1 ;        % Only include complete final year
for yr = start_yr:end_yr
  inds = find(Year == yr) ;
  ann_mean_vol = [ann_mean_vol;mean(yVol(inds))] ;
  ann_mean_yr  = [ann_mean_yr; mean(times(inds))] ;
end % yr

out_data.volume = ann_mean_vol.*1e3 ;       % Unit is now km^3
out_data.time   = ann_mean_yr ;

fprintf(1,' done.\n') ;
end