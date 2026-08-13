%% moudi_path.m
% Interactive 3D globe view (rotate / pan / tilt / zoom with the mouse,
% just like Google Earth) of the MOUDI sampling valve state (open/closed)
% along the flight path.
%
% Requires MATLAB R2020a or later WITH the Mapping Toolbox installed
% (uifigure is base MATLAB, but geoglobe/geoplot3 are Mapping Toolbox
% functions).
%
% Data source: moudieng_1.mat
%
%
%   Lat, Lon      - degrees
%   WGS_84_Alt    - meters (used instead of GPS_MSL_Alt, which is a
%                   sentinel/error value of 99999 for nearly this entire
%                   file - see note below)
%   MMcmd         - valve command: 2 = open, 3 = closed

clear; clc; close all;

%% --- Load data ----------------------------------------------------------
data = load('moudieng_1.mat');

lat   = data.Lat(:);
lon   = data.Lon(:);
alt   = data.WGS_84_Alt(:);   % meters - GPS_MSL_Alt is unreliable in this file (see header note)
valve = data.MMcmd(:);        % 2 = open, 3 = closed

%% --- Clean up invalid samples --------------------------------------------
% Filters NaNs plus the lat==0/lon==0 sentinel row seen in this file.
valid = ~isnan(lat) & ~isnan(lon) & ~isnan(alt) & ~isnan(valve) & lat ~= 0 & lon ~= 0;
lat   = lat(valid);
lon   = lon(valid);
alt   = alt(valid);
valve = valve(valid);

%% --- Filter: keep only samples above an altitude floor -------------------
altThreshold_ft = 0;    % set to e.g. 25000 to restrict to a high-altitude segment
altThreshold_m  = altThreshold_ft * 0.3048;

highAlt = alt > altThreshold_m;

fprintf('%d of %d samples are above %.0f ft (%.1f m)\n', ...
    sum(highAlt), numel(valid), altThreshold_ft, altThreshold_m);

lat   = lat(highAlt);
lon   = lon(highAlt);
alt   = alt(highAlt);
valve = valve(highAlt);

%% --- Valve state mapping ---------------------------------------------
openValue   = 2;
closedValue = 3;
openLabel   = 'Open';
closedLabel = 'Closed';
openColor   = [0.10 0.70 0.10];   % green
closedColor = [0.80 0.10 0.10];   % red

isOpen   = (valve == openValue);
isClosed = (valve == closedValue);

fprintf('%d samples OPEN, %d samples CLOSED, %d unmatched\n', ...
    sum(isOpen), sum(isClosed), sum(~isOpen & ~isClosed));

%% --- Create the interactive 3D globe --------------------------------------
uif = uifigure('Name', 'MOUDI Valve State Along Flight Path', 'Position', [100 100 1050 780]);
g = geoglobe(uif);
hold(g, 'on');

% Plot the flight path as a continuous line first, so the colored valve
% markers sit visually on top of it.
pathColor     = [0.85 0.85 0.85];   % light gray - edit to taste
pathLineWidth = 4;                  % increase for a thicker path

geoplot3(g, lat, lon, alt, '-', ...
    'Color', pathColor, ...
    'LineWidth', pathLineWidth, ...
    'Marker', 'none');

% Plot OPEN and CLOSED samples as two separate marker sets.
% Note: on a geoglobe, geoplot3 returns a specialized Line object whose
% Marker property only accepts 'o' or 'none' - there is no MarkerFaceColor
% or other fill property at all. The workaround: since LineWidth also
% thickens the marker's edge, using a LineWidth close to the MarkerSize
% makes the ring's stroke fill in the center, giving a solid-looking dot.
markerSize      = 5;   % reduce/increase to change dot size
markerLineWidth = 4;   % keep close to markerSize so dots look solid, not ringed

geoplot3(g, lat(isOpen), lon(isOpen), alt(isOpen), 'o', ...
    'Color', openColor, ...
    'MarkerSize', markerSize, ...
    'LineWidth', markerLineWidth, ...
    'LineStyle', 'none');

geoplot3(g, lat(isClosed), lon(isClosed), alt(isClosed), 'o', ...
    'Color', closedColor, ...
    'MarkerSize', markerSize, ...
    'LineWidth', markerLineWidth, ...
    'LineStyle', 'none');

% --- Highlight the exact points where the valve changes state ---------
% A "change" is the first sample of a new state, i.e. where the value
% differs from the previous sample. Plotted again here at double size
% (and double LineWidth, to keep the same solid-looking ratio) so they
% stand out from the regular same-color markers underneath.
isTransition = false(size(valve));
isTransition(2:end) = diff(valve) ~= 0;

fprintf('%d valve state transitions found\n', sum(isTransition));

transOpen   = isTransition & isOpen;
transClosed = isTransition & isClosed;

geoplot3(g, lat(transOpen), lon(transOpen), alt(transOpen), 'o', ...
    'Color', openColor, ...
    'MarkerSize', markerSize * 2, ...
    'LineWidth', markerLineWidth * 2, ...
    'LineStyle', 'none');

geoplot3(g, lat(transClosed), lon(transClosed), alt(transClosed), 'o', ...
    'Color', closedColor, ...
    'MarkerSize', markerSize * 2, ...
    'LineWidth', markerLineWidth * 2, ...
    'LineStyle', 'none');

% Point the camera at the mean location of the flight track.
% After this, use the mouse to rotate/pan/tilt/zoom freely (left-drag =
% rotate, right-drag = tilt, scroll = zoom - same feel as Google Earth).
campos(g, mean(lat), mean(lon), 4e5);   % ~400 km camera altitude to start
camheading(g, 0);
campitch(g, -60);

%% --- Legend reference window -------------------------------------------
% geoglobe is a web-based component that renders on top of everything
% else in its own uifigure, so a legend placed in that same window would
% get hidden underneath it. Instead, show it in its own separate,
% ordinary figure window next to the globe.
legFig = figure('Name', 'Valve State Legend', 'Color', 'w', ...
    'Position', [1160 400 220 150]);
movegui(legFig, 'onscreen');   % nudges the window back on-screen if it landed off the visible display
axis off;
hold on;
scatter(nan, nan, 80, openColor,   'filled', 'DisplayName', openLabel);
scatter(nan, nan, 80, closedColor, 'filled', 'DisplayName', closedLabel);
legend('Location', 'north', 'FontSize', 11);
title('Valve State');
figure(legFig);   % bring the legend window to the front, in case the globe window stole focus