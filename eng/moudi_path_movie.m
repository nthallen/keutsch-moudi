%% moudi_path_movie.m
% Animated "flight tracker" movie of MOUDI sampling valve state
% (open/closed), restricted to samples above an altitude threshold.
% Traces the flight path across a 2D map (colored by valve state), synced
% with a scrolling altitude/valve-status panel, a pressure/flow panel,
% and a temperature panel (6 sensors, shared C scale) below it. Exported
% as an MP4 and/or GIF.
%
% This uses a 2D geoaxes map rather than the interactive 3D geoglobe from
% moudi_path.m - geoglobe is a web-rendered uifigure control that doesn't
% reliably capture frame-by-frame with getframe, so geoaxes (normal,
% capturable axes) is used instead to make the export robust.
%
% Requires MATLAB R2020a or later WITH the Mapping Toolbox installed
% (geoaxes/geoplot/geoscatter are Mapping Toolbox functions).
%
% Data source: moudieng_1.mat
%   Lat, Lon        - degrees
%   WGS_84_Alt      - meters (used instead of GPS_MSL_Alt, which is a
%                     sentinel/error value of 99999 for nearly this
%                     entire file)
%   MMcmd           - valve command: 2 = open, 3 = closed
%   MMstat          - valve status feedback (plotted 0-4)
%   MS5607_P        - pressure, mbar
%   MMFC_VolFlow    - volumetric flow, ccm
%   MS5607_T, PumpT, RPi_T, Amb_T, ValveT, PlateT
%                   - temperature sensors, degrees C
%
% ------------------------- OPTIONS (edit these) -------------------------
altThreshold_ft = 0;            % altitude floor for included samples (ft)

openValue   = 2;                % MMcmd value meaning "open"
closedValue = 3;                % MMcmd value meaning "closed"
openLabel   = 'Open';
closedLabel = 'Closed';
openColor   = [0.10 0.70 0.10]; % green
closedColor = [0.80 0.10 0.10]; % red

% --- SPEED CONTROLS ---
% Rendering time is driven almost entirely by nFrames (= nSamples /
% frameStep). Raising frameStep is the single biggest lever for a faster
% render. fps only changes how fast the finished video PLAYS BACK - it
% does not speed up rendering.
frameStep       = 10;          % use every Nth sample as an animation frame
fps             = 40;          % playback frame rate
outputFormat    = 'mp4';       % 'mp4' | 'gif' | 'both'
                                % GIF is noticeably slower to write (each
                                % frame gets re-quantized to a 256-color
                                % palette) - use 'mp4' unless you specifically
                                % need a GIF, and add 'both' back once
                                % you're happy with the framing/speed.
outFileName     = 'moudi_flight_movie';  % base name, no extension
% --------------------------------------------------------------------

clearvars -except altThreshold_ft openValue closedValue openLabel closedLabel ...
              openColor closedColor frameStep fps outputFormat outFileName;
clc; close all;

%% --- Load data ----------------------------------------------------------
data = load('moudieng_1.mat');

lat   = data.Lat(:);
lon   = data.Lon(:);
alt   = data.WGS_84_Alt(:);      % meters - GPS_MSL_Alt is unreliable in this file
valve = data.MMcmd(:);           % 2 = open, 3 = closed
mmstat = data.MMstat(:);         % status feedback, plotted 0-4

msP  = data.MS5607_P(:);
msT  = data.MS5607_T(:);
volFlow = data.MMFC_VolFlow(:);
pumpT  = data.PumpT(:);
rpiT   = data.RPi_T(:);
ambT   = data.Amb_T(:);
valveT = data.ValveT(:);
plateT = data.PlateT(:);

% Time: seconds since midnight UTC, via time2d (same as pops_path_movie.m)
time = time2d(data.Tmoudieng_1(:));

%% --- Clean up invalid samples --------------------------------------------
% Filters NaNs plus the lat==0/lon==0 sentinel row seen in this file.
valid = ~isnan(lat) & ~isnan(lon) & ~isnan(alt) & ~isnan(valve) & ...
        ~isnan(mmstat) & ~isnan(msP) & ~isnan(msT) & ~isnan(volFlow) & ...
        ~isnan(pumpT) & ~isnan(rpiT) & ~isnan(ambT) & ~isnan(valveT) & ~isnan(plateT) & ...
        ~isnan(time) & lat ~= 0 & lon ~= 0;

%% --- Filter: keep only samples above threshold ---------------------------
altThreshold_m = altThreshold_ft * 0.3048;
highAlt_full = alt > altThreshold_m;   % evaluated pre-mask, applied together below
keep = valid & highAlt_full;

fprintf('%d of %d samples kept (valid + above %.0f ft / %.1f m)\n', ...
    sum(keep), numel(lat), altThreshold_ft, altThreshold_m);

lat     = lat(keep);
lon     = lon(keep);
alt     = alt(keep);
valve   = valve(keep);
mmstat  = mmstat(keep);
msP     = msP(keep);
msT     = msT(keep);
volFlow = volFlow(keep);
pumpT   = pumpT(keep);
rpiT    = rpiT(keep);
ambT    = ambT(keep);
valveT  = valveT(keep);
plateT  = plateT(keep);
time    = time(keep);   % seconds since midnight UTC, drift-corrected

nSamples = numel(lat);
if nSamples < 2
    error('Not enough valid samples above the altitude threshold to animate.');
end

isOpen   = (valve == openValue);
isClosed = (valve == closedValue);

fprintf('%d samples OPEN, %d samples CLOSED, %d unmatched\n', ...
    sum(isOpen), sum(isClosed), sum(~isOpen & ~isClosed));

%% --- Color mapping for valve state (categorical, not continuous) --------
% Unlike the POPS concentration version, this is a two-state category,
% so points get one of two fixed colors rather than a colormap lookup.
% Any sample that matches neither openValue nor closedValue falls back
% to gray so it's still visible rather than silently dropped.
ptColors = repmat([0.5 0.5 0.5], nSamples, 1);
ptColors(isOpen, :)   = repmat(openColor, sum(isOpen), 1);
ptColors(isClosed, :) = repmat(closedColor, sum(isClosed), 1);

%% --- Frames to render -----------------------------------------------------
frameSamples = 2:frameStep:nSamples;
if frameSamples(end) ~= nSamples
    frameSamples(end+1) = nSamples;   % always include the final point
end
nFrames = numel(frameSamples);

% Trail is built from only the decimated frame samples (nFrames points
% total), not every raw sample up to the current index, to keep
% rendering fast regardless of frameStep.
plotLat    = lat(frameSamples);
plotLon    = lon(frameSamples);
plotColors = ptColors(frameSamples, :);

fprintf('Rendering %d frames (every %d-th sample of %d total)...\n', ...
    nFrames, frameStep, nSamples);

%% --- Build the figure layout ----------------------------------------------
fig = figure('Color', 'w', 'Position', [100 100 1000 950]);
tl  = tiledlayout(fig, 6, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

% -- Map panel (top 3 rows) --
axMap = geoaxes(tl);
axMap.Layout.Tile     = 1;
axMap.Layout.TileSpan = [3 1];
geobasemap(axMap, 'topographic');   % swap to 'grayland' for a faster,
                                     % offline-friendly vector basemap
hold(axMap, 'on');
title(axMap, 'MOUDI Valve State Along Flight Path');

% Full flight path in light gray for context, visible from frame 1.
geoplot(axMap, lat, lon, '-', 'Color', [0.75 0.75 0.75], 'LineWidth', 1.5);

% Handles updated every frame: growing colored trail + a bright "current
% position" marker riding at the head of it.
trailPlot = geoscatter(axMap, plotLat(1), plotLon(1), 18, plotColors(1,:), 'filled');
headPlot  = geoplot(axMap, plotLat(1), plotLon(1), 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 1.5);

% Discrete legend for valve state (a normal geoaxes captures fine with
% getframe, unlike geoglobe, so a real legend works directly here).
legOpen   = geoscatter(axMap, nan, nan, 40, openColor,   'filled', 'DisplayName', openLabel);
legClosed = geoscatter(axMap, nan, nan, 40, closedColor, 'filled', 'DisplayName', closedLabel);
legend(axMap, [legOpen, legClosed], 'Location', 'southoutside', 'Orientation', 'horizontal');

% -- Altitude + valve status panel (row 4) --
axTS = nexttile(tl, 4);
yyaxis(axTS, 'left');
plot(axTS, time, alt/0.3048, '-', 'Color', [0.3 0.3 0.7]);
ylabel(axTS, 'Altitude (ft)');
yyaxis(axTS, 'right');
plot(axTS, time, mmstat, '-', 'Color', [0.7 0.3 0.3]);
ylim(axTS, [0 4]);
ylabel(axTS, 'MMstat');
set(axTS, 'YTick', [0 1 3], 'YTickLabel', {'Transition', 'Open', 'Closed'});
xlim(axTS, [min(time) max(time)]);
grid(axTS, 'on');
cursorLine = xline(axTS, min(time), 'k-', 'LineWidth', 1.5);

% -- Sensor panel: pressure (left) / vol. flow (right) --------------------
axSensors = nexttile(tl, 5);
pColor = [0.00 0.45 0.74];   % blue
vColor = [0.47 0.67 0.19];   % green

yyaxis(axSensors, 'left');
plot(axSensors, time, msP, '-', 'Color', pColor);
ylabel(axSensors, 'MS5607 Pressure (mbar)');
axSensors.YColor = pColor;

yyaxis(axSensors, 'right');
plot(axSensors, time, volFlow, '-', 'Color', vColor);
ylabel(axSensors, 'MMFC Vol. Flow (ccm)');
axSensors.YColor = vColor;

xlim(axSensors, [min(time) max(time)]);
grid(axSensors, 'on');
cursorLine2 = xline(axSensors, min(time), 'k-', 'LineWidth', 1.5);

% -- Temperature panel: all 6 temperature sensors, shared C scale --------
axTemps = nexttile(tl, 6);
hold(axTemps, 'on');
tempFields = {'MS5607_T', 'PumpT', 'RPi_T', 'Amb_T', 'ValveT', 'PlateT'};
tempData   = [msT, pumpT, rpiT, ambT, valveT, plateT];
tempColors = lines(numel(tempFields));
for ii = 1:numel(tempFields)
    plot(axTemps, time, tempData(:, ii), '-', 'Color', tempColors(ii, :), ...
        'DisplayName', strrep(tempFields{ii}, '_', '\_'));
end
legend(axTemps, 'Location', 'eastoutside', 'FontSize', 8);
ylabel(axTemps, 'Temperature (\circC)');
xlabel(axTemps, 'Time (UTC, HH:MM)');
xlim(axTemps, [min(time) max(time)]);
grid(axTemps, 'on');
cursorLine3 = xline(axTemps, min(time), 'k-', 'LineWidth', 1.5);

linkaxes([axTS axSensors axTemps], 'x');

% Format tick labels as HH:MM UTC instead of raw seconds-since-midnight.
xticklabels(axTS, secToClockStr(xticks(axTS)));
xticklabels(axTemps, secToClockStr(xticks(axTemps)));

%% --- Set up video/gif writers ----------------------------------------------
writeMP4 = any(strcmpi(outputFormat, {'mp4', 'both'}));
writeGIF = any(strcmpi(outputFormat, {'gif', 'both'}));

if writeMP4
    if ispc || ismac
        vw = VideoWriter([outFileName '.mp4'], 'MPEG-4');
    else
        % The MPEG-4 VideoWriter profile isn't available on Linux - fall
        % back to an AVI container (still a normal playable video file).
        vw = VideoWriter([outFileName '.avi'], 'Motion JPEG AVI');
        warning('MPEG-4 not supported on this platform - writing an AVI instead.');
    end
    vw.FrameRate = fps;
    open(vw);
end
gifFile = [outFileName '.gif'];

%% --- Animate + capture ------------------------------------------------------
for f = 1:nFrames
    k = frameSamples(f);

    set(trailPlot, 'LatitudeData', plotLat(1:f), 'LongitudeData', plotLon(1:f), ...
        'CData', plotColors(1:f, :));
    set(headPlot, 'LatitudeData', lat(k), 'LongitudeData', lon(k));
    cursorLine.Value  = time(k);
    cursorLine2.Value = time(k);
    cursorLine3.Value = time(k);

    drawnow;
    frame = getframe(fig);

    if writeMP4
        writeVideo(vw, frame);
    end
    if writeGIF
        [imind, cmapGif] = rgb2ind(frame.cdata, 256);
        if f == 1
            imwrite(imind, cmapGif, gifFile, 'gif', 'Loopcount', inf, ...
                'DelayTime', 1/fps);
        else
            imwrite(imind, cmapGif, gifFile, 'gif', 'WriteMode', 'append', ...
                'DelayTime', 1/fps);
        end
    end
end

if writeMP4
    close(vw);
    fprintf('Saved %s\n', vw.Filename);
end
if writeGIF
    fprintf('Saved %s\n', gifFile);
end

%% --- Local functions --------------------------------------------------------
function labels = secToClockStr(secVals)
% Format seconds-since-midnight as 'HH:MM' UTC strings for axis ticks.
secVals = mod(secVals, 86400);
hh = floor(secVals / 3600);
mm = round(mod(secVals, 3600) / 60);
mm(mm == 60) = 0;
labels = arrayfun(@(h, m) sprintf('%02d:%02d', h, m), hh, mm, 'UniformOutput', false);
end

function tout = time2d(t, m, s)
% tout = time2d(t);
% t is seconds since 1970 UTC
% tout is seconds since midnight UTC
%
% tout = time2d(h,m,s);
% tout is seconds
if nargin == 1
    t1 = t(find(~isnan(t), 1));
    day = fix(t1./(24*60*60));
    tout = t - day*60*24*60;
else
    tout = t*3600 + m*60 + s;
end
end