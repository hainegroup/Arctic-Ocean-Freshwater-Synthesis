function [CESM_freshwater_data,IVT_stats,threshold_data] = read_and_process_CESM_data(CESM_LE_filename,CESM_LW_filename,CESM_control_filename)
% Function to read the CESM freshwater data, process them, and compute the
% shift and emergence times.
% twnh Aug '20

%% Read CESM data
CESM_freshwater_data.CESM_LE      = read_CESM_data(CESM_LE_filename) ;
CESM_freshwater_data.CESM_LW      = read_CESM_data(CESM_LW_filename) ;
CESM_freshwater_data.CESM_control = read_CESM_data(CESM_control_filename) ;

%% Compute control run statistics for IVT
IVT_stats = compute_IVT_statistics(CESM_freshwater_data.CESM_control) ;

%% Find shift and emergence years
threshold_data.CESM_LE = compute_threshold_data(CESM_freshwater_data.CESM_LE,IVT_stats) ;
threshold_data.CESM_LW = compute_threshold_data(CESM_freshwater_data.CESM_LW,IVT_stats) ;

end

%% Local functions
function CESM_data = read_CESM_data(filename)
% Read Alex's netcdf files:

fprintf(1,' Reading CESM_LE_data data file [%s]...',filename) ;
CESM_data.times                           = double(ncread(filename,'time')) ;
CESM_data.FW_flux_Fram_annual_net         = double(ncread(filename,'FW_flux_Fram_annual_net')) ;
CESM_data.Solid_FW_flux_Fram_annual_net   = double(ncread(filename,'Solid_FW_flux_Fram_annual_net')) ;
CESM_data.FW_flux_Barrow_annual_net       = double(ncread(filename,'FW_flux_Barrow_annual_net')) ;
CESM_data.Solid_FW_flux_Barrow_annual_net = double(ncread(filename,'Solid_FW_flux_Barrow_annual_net')) ;
CESM_data.FW_flux_Nares_annual_net        = double(ncread(filename,'FW_flux_Nares_annual_net')) ;
CESM_data.Solid_FW_flux_Nares_annual_net  = double(ncread(filename,'Solid_FW_flux_Nares_annual_net')) ;
CESM_data.FW_flux_Davis_annual_net        = double(ncread(filename,'FW_flux_Davis_annual_net')) ;
CESM_data.Solid_FW_flux_Davis_annual_net  = double(ncread(filename,'Solid_FW_flux_Davis_annual_net')) ;
CESM_data.FW_flux_BSO_annual_net          = double(ncread(filename,'FW_flux_BSO_annual_net')) ;
CESM_data.Solid_FW_flux_BSO_annual_net    = double(ncread(filename,'Solid_FW_flux_BSO_annual_net')) ;
CESM_data.FW_flux_Bering_annual_net       = double(ncread(filename,'FW_flux_Bering_annual_net')) ;
CESM_data.Solid_FW_flux_Bering_annual_net = double(ncread(filename,'Solid_FW_flux_Bering_annual_net')) ;
CESM_data.runoff_annual                   = double(ncread(filename,'runoff_annual')) ;
CESM_data.netPrec_annual                  = double(ncread(filename,'netPrec_annual')) ;
CESM_data.Liquid_FW_storage_Arctic_annual = double(ncread(filename,'Liquid_FW_storage_Arctic_annual')) ;
CESM_data.Solid_FW_storage_Arctic_annual  = double(ncread(filename,'Solid_FW_storage_Arctic_annual')) ;
fprintf(1,'done.\n') ;

end

function IVT_stats = compute_IVT_statistics(data)
% Compute the thresholds for each timeseries from the control run.

field_names = fieldnames(data) ;
for ff = 1:length(field_names)
    this_fld = field_names{ff} ;
    if(~strcmp(this_fld,'times'))
        std_val = std( data.(this_fld)) ;
        meanval = mean(data.(this_fld)) ;
        IVT_stats.(this_fld).max = meanval + 3.5*std_val ;          % 3.5 sigma limits 
        IVT_stats.(this_fld).min = meanval - 3.5*std_val ;          % 3.5 sigma limits
    end % if
end % ff

end

function threshold_data = compute_threshold_data(data,IVT_stats)
% Compute the year of shift and emergence for each timeseries for each
% member. This code is based on Alex's ncl code.

field_names = fieldnames(data) ;
Nfld        = length(field_names) ;

% Find shift and emergence years
for ff = 1:Nfld             % Loop over fields
    this_fld = field_names{ff} ;
    if(~strcmp(this_fld,'times'))
        this_min = IVT_stats.(this_fld).min ;
        this_max = IVT_stats.(this_fld).max ;
        %Nm       = size(data.(this_fld),1) ;
        Nm = 11 ; % Hard code 11 to override the 40 CESM-LE members
        threshold_data.(this_fld).shift_yr = zeros(Nm,1) ;
        threshold_data.(this_fld).emerg_yr = zeros(Nm,1) ;
        for mm = 1:Nm             % Loop over ensemble members
            this_series = data.(this_fld)(mm,:)' ;
            
            % Detect shift:
            min_ind = find_zero_crossing(this_series - this_min) ;
            max_ind = find_zero_crossing(this_series - this_max) ;
            this_shift_ind = min([min_ind; max_ind]) ;
            if(this_shift_ind < 999999)
                this_shift_yr = data.times(this_shift_ind) ;
            end % if
            threshold_data.(this_fld).shift_yr(mm) = this_shift_yr ;
            
            % Detect emergence: same criterion as a shift, but working
            % backwards from the final time.
            this_series_flip = flipud(this_series) ;
            this_times_flip  = flipud(data.times) ;
            if(    this_series_flip(1) < this_min)
                ind = find_zero_crossing(this_series_flip - this_min) ;
            elseif(this_series_flip(1) > this_max)
                ind = find_zero_crossing(this_series_flip - this_max) ;
            else
                ind = 999999 ;
            end % if
            if(ind < 999999)
                this_emerg_yr = this_times_flip(ind) ;
            end % if
            threshold_data.(this_fld).emerg_yr(mm) = this_emerg_yr ;
            
        end % mm
    end % if
end % ff

end

function index = find_zero_crossing(series)
% Find index of first zero crossing of series

tmp = find(sign(series) ~= sign(series(1))) ;
if(~isempty(tmp))
    index = min(tmp) ;
else
    index = 999999 ;        % No zero crossing in series.
end % if

end