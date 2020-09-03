% Schematic figure for GRL commentary article
% twnh Aug '20 with code and data from Jahn & Laiho (2020).

%% Setup
close all
clear
clear global
more off
fprintf(1,'\n Schematic figure for GRL commentary.\n Plots Jahn & Laiho (2020) CESM data (like their Fig. 2) and updated synthesized flux observations from Haine et al. (2015).\n twnh Aug ''20\n\n') ;

% Read CESM data files from Alex.
[CESM_freshwater_data,IVT_stats,threshold_data] = read_and_process_CESM_data(...
    '../data/From Alex/FW_data_CESM_LE_1920_2100.nc',...
    '../data/From Alex/FW_data_CESM_2deg_2006_2100.nc',...
    '../data/From Alex/FW_data_CESM_LE_400_2199_control.nc') ;

% Read updated flux synthsis data from Hetal15.
filename = '../data/updated_data/flux_data' ;
fprintf(1,'\n Loading ASOF flux data from [%s]...',filename) ;
load(filename,'flux_data') ;
ASOF_freshwater_data = flux_data ;
clear flux_data filename
fprintf(1,'done.\n\n') ;

%% Plot results. These subplots are combined in keynote.
fld_names = fieldnames(CESM_freshwater_data.CESM_control) ;
plot_data = setup_plot_data(fld_names) ;

% Plot CESM results and Alex's thresholds and updated Haine et al. (2015) data
Np = length(fld_names) ;
for pp = 1:Np
    this_fld = fld_names{pp} ;
    if(plot_data.(this_fld).plot_flag)
        make_plot(plot_data,CESM_freshwater_data,IVT_stats,threshold_data,this_fld,ASOF_freshwater_data) ;
    end % if
end % pp
close(plot_data.fig2)

%% Local functions
function plot_data = setup_plot_data(flds)
% Configure plot options and open subplots

plot_data.colours.purple = [116  59 147]./256 ;
plot_data.colours.gray   = [165 165 165]./256 ;
plot_data.colours.green  = [111 150  80]./256 ;
plot_data.colours.ASOF   = [227  10  15]./256 ;
plot_data.linestyle.ASOF = '-' ;
plot_data.linewidth.ASOF = 2 ;
plot_data.halowidth.ASOF = 6 ;
plot_data.linewidth.threshold = 2 ;
plot_data.linewidth.IVT  = 1 ;

plot_data.fig1 = figure(1) ;       % Used to print individual figure files.
wysiwyg_local
plot_data.fig2 = figure(2) ;       % Final figure with all subplots.
wysiwyg_local
figure(plot_data.fig1) ;

% Loop over CESM freshwater diagnostic fields:
for ff = 1:length(flds)
    fld = flds{ff} ;
    plot_data.(fld).xlabel = 'year' ;
    plot_data.(fld).ylabel = 'FW flux [km^3/year]' ;
    plot_data.(fld).XLims  = [1920 2100] ;
    plot_data.(fld).YLims  = [-6000 1000] ;
    
    if(strcmp(fld,'Liquid_FW_storage_Arctic_annual'))
        plot_data.(fld).YLims  = [60000 140000] ;
        plot_data.(fld).ylabel = 'FW storage [km^3]' ;
    elseif (strcmp(fld,'Solid_FW_storage_Arctic_annual'))
        plot_data.(fld).YLims  = [0 80000] ;
        plot_data.(fld).ylabel = 'FW storage [km^3]' ;
    elseif(contains(fld,'FW_flux_Bering') || contains(fld,'runoff') || contains(fld,'netPrec'))
        plot_data.(fld).YLims  = [-1000 6000] ;
    end % if
    
    plot_data.(fld).plot_flag = false ;
    switch fld
        case 'FW_flux_Fram_annual_net'
            plot_data.(fld).plot_flag = true ;
            plot_data.(fld).handle = subplot(5,2,1) ;
            plot_data.(fld).title = 'Liquid Fram' ;
        case 'Solid_FW_flux_Fram_annual_net'
            plot_data.(fld).plot_flag = true ;
            plot_data.(fld).handle = subplot(5,2,2) ;
            plot_data.(fld).title = 'Solid Fram' ;
        case 'FW_flux_Davis_annual_net'
            plot_data.(fld).plot_flag = true ;
            plot_data.(fld).handle = subplot(5,2,3) ;
            plot_data.(fld).title = 'Liquid Davis' ;
        case 'FW_flux_Bering_annual_net'
            plot_data.(fld).plot_flag = true ;
            plot_data.(fld).handle = subplot(5,2,4) ;
            plot_data.(fld).title = 'Liquid Bering' ;
        case 'Liquid_FW_storage_Arctic_annual'
            plot_data.(fld).plot_flag = true ;
            plot_data.(fld).handle = subplot(5,2,5) ;
            plot_data.(fld).title = 'Liquid storage' ;
        case 'Solid_FW_storage_Arctic_annual'
            plot_data.(fld).plot_flag = true ;
            plot_data.(fld).handle = subplot(5,2,6) ;
            plot_data.(fld).title = 'Solid storage' ;
    end % switch
    pbaspect([466 232 1]) ;         % Plot box aspect ratio measured from Alex's figure.
end % ff

end

function make_plot(plot_data,fw_data,IVT_stats,th_data,fld,ASOF_data)
% Function to make subplot for field fld in fw_data struct. Also add
% ASOF_data as appropriate.

figure(plot_data.fig1)
subplot(plot_data.(fld).handle)
hold on
grid on
set(gca,'box','on')

% Plot CESM_LE 1st 11 members (as per JL20) and CESM_LW:
for mm = 1:11
    inds1 = (fw_data.CESM_LE.times <= 2006) ;
    inds2 = (fw_data.CESM_LE.times >= 2006) ;
    plot(fw_data.CESM_LE.times(inds1),fw_data.CESM_LE.(fld)(mm,inds1),'-','color',plot_data.colours.gray) ;
    plot(fw_data.CESM_LE.times(inds2),fw_data.CESM_LE.(fld)(mm,inds2),'-','color',plot_data.colours.purple) ;
    plot(fw_data.CESM_LW.times       ,fw_data.CESM_LW.(fld)(mm,:    ),'-','color',plot_data.colours.green) ;
end % mm

% Futz
tit_xloc = plot_data.(fld).XLims(1) + (plot_data.(fld).XLims(2) - plot_data.(fld).XLims(1))*0.025 ;
tit_yloc = plot_data.(fld).YLims(2) - (plot_data.(fld).YLims(2) - plot_data.(fld).YLims(1))*0.10 ;
text(tit_xloc,tit_yloc,plot_data.(fld).title,'fontweight','normal','fontsize',12,'backgroundcolor','w','margin',0.5) ;
xlabel(plot_data.(fld).xlabel)
ylabel(plot_data.(fld).ylabel)
set(gca,'XLim',plot_data.(fld).XLims) ;
set(gca,'YLim',plot_data.(fld).YLims) ;

% Plot thresholds and minimum shift/emergence years. But don't plot CESM_LW
% shift if there's a CESM_LE shift prior to 2006 (because they coincide
% during this period).
h = plot(plot_data.(fld).XLims,IVT_stats.(fld).max.*[1 1],'k-','linewidth',plot_data.linewidth.IVT) ;
uistack(h,'bottom') ;
h = plot(plot_data.(fld).XLims,IVT_stats.(fld).min.*[1 1],'k-','linewidth',plot_data.linewidth.IVT) ;
uistack(h,'bottom') ;
plot_shift_emergence(th_data.CESM_LE.(fld),th_data.CESM_LW.(fld),plot_data.colours,plot_data.linewidth.threshold) ;

%% Add ASOF data series to plot
switch fld
    case 'FW_flux_Fram_annual_net'
        pts = [ASOF_data.FramStrait.liquid_time,ASOF_data.FramStrait.liquid_flux] ;
    case 'Solid_FW_flux_Fram_annual_net'
        pts = [ASOF_data.FramStrait.solid_time,ASOF_data.FramStrait.solid_flux] ;
    case 'FW_flux_Davis_annual_net'
        pts = [ASOF_data.DavisStrait.liquid_time,ASOF_data.DavisStrait.liquid_flux] ;
    case 'FW_flux_Bering_annual_net'
        pts = [ASOF_data.BeringStrait.liquid_time,ASOF_data.BeringStrait.liquid_flux] ;
    case 'Liquid_FW_storage_Arctic_annual'
        pts = [ASOF_data.liquid_Storage.time,ASOF_data.liquid_Storage.volume.*(93000-19000)./93000] ;       % 19000 km^3 correction is due to Alex's omission of Baffin Bay. See Hetal15 section 2.1.
    case 'Solid_FW_storage_Arctic_annual'
        pts = [ASOF_data.solid_Storage.time,ASOF_data.solid_Storage.volume] ;
end % switch

% Cut NaN and plot twice to give white halo.
inds = find(~isnan(pts(:,2))) ;
plot(pts(inds,1),pts(inds,2),'linestyle',plot_data.linestyle.ASOF,'linewidth',plot_data.halowidth.ASOF,'color','w') ;
plot(pts(inds,1),pts(inds,2),'linestyle',plot_data.linestyle.ASOF,'linewidth',plot_data.linewidth.ASOF,'color',plot_data.colours.ASOF) ;

% Print each subplot individually to file to make keynote import more
% consistent and easy.
filename = ['schematic_',fld] ;
fprintf(1,' Writing figure to [%s]...',filename) ;
new_obj = copyobj(plot_data.(fld).handle,plot_data.fig2) ;
figure(plot_data.fig2) ;
print(plot_data.fig2,'-depsc',filename) ;
delete(new_obj) ;
figure(plot_data.fig1) ;
fprintf(1,'done.\n') ;

end

function plot_shift_emergence(th_data_CESM_LE,th_data_CESM_LW,colours,width)
% function to plot the shift and emergence times from JL20.

YLims = get(gca,'YLim') ;

if(0)       % Don't plot shifts to avoid clutter in figure.
    flag = 0 ;
    % Shift:
    shift_yr = min(th_data_CESM_LE.shift_yr) ;
    if(shift_yr <= 2006  && shift_yr > 1000)
        h = plot(shift_yr.*[1 1],YLims,'--','color',colours.gray,'linewidth',width) ;
        flag = 1 ;
    elseif(shift_yr < 2090)
        h = plot(shift_yr.*[1 1],YLims,'--','color',colours.purple,'linewidth',width) ;
    end % if
    uistack(h,'bottom') ;
    
    if(flag~=1)
        shift_yr = min(th_data_CESM_LW.shift_yr) ;
        if(shift_yr <= 2006  && shift_yr > 1000)
            h = plot(shift_yr.*[1 1],YLims,'--','color',colours.gray,'linewidth',width) ;
        elseif(shift_yr < 2090)
            h = plot(shift_yr.*[1 1],YLims,'--','color',colours.green,'linewidth',width) ;
        end % if
        uistack(h,'bottom') ;
    end % if
    
end % if

% Emergence:
emerg_yr = min(th_data_CESM_LE.emerg_yr) ;
if(emerg_yr > 1000 && emerg_yr < 2090)
    h = plot(emerg_yr.*[1 1],YLims,'-','color',colours.purple,'linewidth',width) ;
    uistack(h,'bottom') ;
end % if
emerg_yr_LE = emerg_yr ;

emerg_yr = min(th_data_CESM_LW.emerg_yr) ;
if(emerg_yr > 1000 && emerg_yr > emerg_yr_LE  && emerg_yr < 2090)
    h = plot(emerg_yr.*[1 1],YLims,'-','color',colours.green,'linewidth',width) ;
    uistack(h,'bottom') ;
end % if

end

function wysiwyg_local
%WYSIWYG -- this function is called with no args and merely
%       changes the size of the figure on the screen to equal
%       the size of the figure that would be printed, 
%       according to the papersize attribute.  Use this function
%       to give a more accurate picture of what will be 
%       printed.
%       Dan(K) Braithwaite, Dept. of Hydrology U.of.A  11/93
 
orient tall
unis = get(gcf,'units');
ppos = get(gcf,'paperposition');
set(gcf,'units',get(gcf,'paperunits'));
pos = get(gcf,'position');
pos(3:4) = ppos(3:4);
set(gcf,'position',pos);
set(gcf,'units',unis);
drawnow

end