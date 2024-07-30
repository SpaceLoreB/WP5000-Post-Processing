%% INPUT
% Import file(s)
% % - add UI for selection
rawData = importWPcsv("C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing\UniBz_W 000024_C2dH.csv", [2, Inf]);
% Create structure
% % variable name
cfgName = 'C3';

%% Working parameters
h_w = 350;    % work height [cm]
vmin_usable = 4;   % usable air speed [m/s]
% how to process: 'abs' = abs. val. of velocities,
% 'x' = x-component,
% 'xz' = xz-component (vertical)
procMethod = 'abs';

% % prepare output structure
% % carrying over parameters to enfore checks when comparing
outStr = struct('params',[h_w vmin_usable],'method',procMethod);    % no real need to carry over h_w right now, only doing it for safety

%% PROCESS, STORE
outStr.L = processSide(rawData,'L');
outStr.R = processSide(rawData,'R');
% 
% assignin("base",varName,outStr)
% clear outStr

%% COMPARE, PLOT, SAVE
%% Format ISO-compl. tables
% (usable, up to w_h --> bicolor?)
makeResTable(outStr,cfgName);

%%  Format summary table (as per original)
% need to divide usable vol into above/below WH
% get angle at WH (make sure it agrees with table)

%% Plot velocities

%% Plot flowrates
% WPcompPlot
%% Plot angles (?)

%% DECLARATIONS