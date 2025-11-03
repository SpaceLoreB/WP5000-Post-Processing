% usual directory switcheroo
workPath = 'C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing';
dpath = uigetdir;

% % how many sides
nSides = 1;
h_w = 500;    % work height [cm]
vmin_usable = 0;   % usable air speed [m/s]
procMethod = 'x';

%% Files selection
cd(dpath);
dname = uigetfile({'*.csv','CSV Files (.csv)'},['Select file for side #'],'MultiSelect','on');
cd(workPath);
cfgName = input('Enter configuration name: ','s');  % I've learnt the hard way that I shouldn't overwrite variables.

for j = 1:length(dname)
    repName = [cfgName '_' num2str(j)];
    % pr            epare input structure
    inStr = rawData2componentArray( importWPcsv([dpath '\' dname{j}], [2, Inf]) );
    % %% statistiche
    [v_valid, v_absolute, I,J] = validate_Velocities(inStr.velComponents, 1);
    % %% Usual processing
    outStr = processSide(v_valid);
    outStr.z = inStr.localZ;
    outStr.stats = velocity_Stats(v_absolute);
    muStd = [ mean( outStr.Q( outStr.Q(:,1) ~= 0 , 1) ); std( outStr.Q( outStr.Q(:,1) ~= 0 , 1) ) ];
    outStr.muStdCV = [muStd; muStd(2)./muStd(1).*100];
    % %% save
    assignin('base',repName,outStr);
    disp(dname{j})
    disp(outStr)
end

%% aggregazione
spM = evalVariability(rep_1,rep_2,rep_3,rep_4);
plotVariability(spM,rep_1.z)

%%
% making "fake" configurations using the #1 and the average volumes.
% might as well average all teh rest, but in due time
spA = spoutA_1;
spA.Q = [spoutA_avg(:,1) spoutA_avg(:,1)];
cvA = std( spA.Q(:,1) )/mean( spA.Q(:,1) );
totA = sum(spA.Q(:,1)); 

spB = spoutB_1;
spB.Q = [spoutB_avg(:,1) spoutB_avg(:,1)];
cvB = std( spB.Q(:,1) )/mean( spB.Q(:,1) );
totB = sum(spB.Q(:,1));
%% plotti
flowRatesPlot_Multi(spB, spA)

%%-- 10.09.25 15:55 --%
Z = spoutA_1.z;
gA = plotVariability(spoutA_avg,Z)
gB = plotVariability(spoutB_avg,Z)