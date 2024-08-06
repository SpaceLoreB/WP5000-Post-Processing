function rawFile = importWPcsv(filename, dataLines)
%IMPORTFILE Import data from a text file
%  C3DH = IMPORTFILE(FILENAME) reads data from text file FILENAME for
%  the default selection.  Returns the data as a table.
%
%  C3DH = IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  C3dH = importfile("C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing\UniBz_W 000024_C3dH.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 11-Jun-2024 16:34:14
% EDITED BY LORENZO BECCE FROM THAT DAY ON

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 7);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["Var1", "side", "px", "py", "vx", "vy", "vz"];
opts.SelectedVariableNames = ["side", "px", "py", "vx", "vy", "vz"];
opts.VariableTypes = ["string", "categorical", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var1", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "side"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["px", "py", "vx", "vy", "vz"], "DecimalSeparator", ",");
opts = setvaropts(opts, ["px", "py", "vx", "vy", "vz"], "ThousandsSeparator", ".");

% Import the data
rawFile = readtable(filename, opts);
% % t.d.: Filter out NaNs!!
rawFile.side = categorical(rawFile.side,{'VL' 'NL' 'NR' 'VR'},{'L' 'L' 'R' 'R'});
end