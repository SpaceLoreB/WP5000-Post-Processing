%% declarations
workPath = 'C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing';
dpath = uigetdir;

% side = 'L';
% model = 'Storm';

%% input raw
while(1)
cd(dpath);
dname = uigetfile({'*.csv','CSV Files (.csv)'},'Select file for side #');
cfgName = input('Enter configuration name: ','s');  % I've learnt the hard way that I shouldn't overwrite variables.
cd(workPath);

% define name
% rawName = [model '_' cfgName '_' side];
% disp(rawName);

inStr = rawData2componentArray( importWPcsv([dpath '\' dname], [2, Inf]) );
% assignin('base',rawName,inStr);
assignin('base',cfgName,inStr);

end
cd(workPath);
%%
