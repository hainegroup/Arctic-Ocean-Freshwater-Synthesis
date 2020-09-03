% Script to make a basemap liquid freshwater figure for the GRL commentary
% article. Based on Fig. 6 of Hetal15.
% twnh Dec 2013, Aug 2020

%% Housekeeping
more off
close all
clear
fprintf(1,'\n make_LFC_map.m\n Script to produce a figure of LFC.\n twnh Dec 13, Aug 20.\n\n') ;

%% Parameters
domain_width  = 1 ;
domain_color  = 'r' ;
gateway_width = 3 ;
gateway_color = 'r' ;

%% Read LFW  maps. From Kial's code, Dec 2013.
fprintf(1,' Reading LFW fields...') ;
lfw_lon   = readbin('../data/From Kial/LONC.bin'   ,[592,464],1,'real*4');
lfw_lat   = readbin('../data/From Kial/LATC.bin'   ,[592,464],1,'real*4');
lfw       = readbin('../data/From Kial/lfw_phc.bin',[592,464],1,'real*4');

%% Main map
ax1    = axes('position',[0.25,0.42,0.50,0.50]) ;
axes(ax1) ;
m_proj('stereographic','lat',90,'long',-30,'radius',25);
hold on

%% Read elevation data to mask the LFW field.
[elev,elev_lon,elev_lat] = m_tbase([-180 180 50 90]) ;
elev_on_lfw_grid         = interp2(elev_lon,elev_lat,elev,lfw_lon,lfw_lat) ;
inds                     = find(elev_on_lfw_grid > 0) ;
lfw(inds)                = NaN ;
fprintf(1,'done.\n') ;

%% Pcolor liquid freshwater (changes renderer to bit mapper)
m_pcolor(lfw_lon,lfw_lat,lfw) ;
hold on
shading flat    % Avoid interp if using painters as the renderer (very large files result).
col_h2 = colorbar('southoutside') ;
set(col_h2,'position',[0.30 0.40 0.40 0.015]) ;
m_text(-30,59,'Liquid freshwater content (m)','fontsize',12,'horizontalalignment','c') ;
set(col_h2,'YTick',[0:5:30]) ;
caxis([0 30])

%% Draw coasts:
m_gshhs('ic','color','k','linewidth',0.5) ;
m_gshhs('ir','color','y','linewidth',0.5) ;

%% Add grid
m_grid('xtick',12,'tickdir','out','ytick',[70 80],'linest','-','xticklabels',[],'yticklabels',[],'fontsize',9) ;
tmp = get(ax1,'XLim') ;
radius = tmp(2) ;
axis([-radius radius -radius radius]) ;
orient tall
wysiwyg

%% Add names and labels
axes(ax1) ;

% Fram Strait
lons = -20:2:10 ;
lats = 78.8.*ones(size(lons)) ;
m_line(lons,lats,'linewidth',domain_width,'color',domain_color) ;
lons = -7:2:9 ;
lats = 78.8.*ones(size(lons)) ;
m_line(lons,lats,'linewidth',gateway_width,'color',gateway_color) ;

% Davis Strait
lons = -61.5:-53.5 ;
lats = 66.6:(67.4-66.6)/(length(lons)-1):67.4 ;
m_line(lons,lats,'linewidth',gateway_width,'color',gateway_color) ;

% Bering Strait
lons = -168:-0.2:-169.8 ;
lats = 65.8:(66.0-65.8)/(length(lons)-1):66.0 ;
m_line(lons,lats,'linewidth',gateway_width,'color',gateway_color) ;

% BSO
lons = 16.5:0.5:20.5 ;
lats = 76.4:(70.25-76.4)/(length(lons)-1):70.25 ;
m_line(lons,lats,'linewidth',domain_width,'color',domain_color) ;

% Lancaster Sound.
% Position from http://www.bio.gc.ca/science/research-recherche/ocean/ice-glace/archipelago-archipel-eng.php
lons = -91.0:0.1:-90.2 ;
lats = 74.0:(74.6-74.0)/(length(lons)-1):74.6 ;
m_line(lons,lats,'linewidth',gateway_width,'color',gateway_color) ;
 
% Nares Str.
% From http://muenchow.cms.udel.edu/papers/MuenchowMelling2008JMR.pdf
lons = -69.0:0.1:-67.0 ;
lats = 80.5:(80.3-80.5)/(length(lons)-1):80.3 ;
m_line(lons,lats,'linewidth',gateway_width,'color',gateway_color) ;

%%  Final output:
print -dpdf LFC_map.pdf