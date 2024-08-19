%% INPUT
% Import file(s)
% UI for selection
[dname, dpath] = uigetfile({'*.csv','CSV Files (.csv)'},'Select file');
rawData = importWPcsv([dpath dname], [2, Inf]);
% Create structure
% % variable name
originalCfgName = input('Enter configuration name: ','s');  % I've learnt the hard way that I shouldn't overwrite variables.

%% Working parameters
h_w = 300;    % work height [cm]
% A sane individual would use one unit throughout the code. I am not that individual.
vmin_usable = 3;   % usable air speed [m/s]
% how to process: 'abs' = abs. val. of velocities,
% 'x' = x-component,
% 'xz' = xz-component (vertical)
procMethod = 'x';

% % prepare output structure
% % carrying over parameters to enfore checks when comparing
outStr = struct('params',[h_w vmin_usable],'method',procMethod);    % no real need to carry over h_w right now, only doing it for safety
% % to-do: pick both y: if equal, assign them to general structure,
% otherwise make comprehensive z-vector, adapt results of both (...) sides
cfgName = sprintf('%s_%s_%i_%i',originalCfgName,outStr.method,outStr.params);
disp(['new configuration name: ' cfgName])
%% PROCESS, STORE
outStr.L = processSide(rawData,'L');
outStr.R = processSide(rawData,'R');

% Calculating results table
outStr.results = produceResults(outStr);

% Keep working through the same cfg, then save it with chosen name at
% last (and export to storable file)
assignin("base",cfgName,outStr)
% clear outStr

% % % Pretty much the end of the processing. Now produce some readable and
% (hopefully) usable output

%% COMPARE, PLOT, SAVE
% %% Format ISO-compl. tables
% (usable, up to w_h --> bicolor?)
% makeResTable(outStr,cfgName);

% %%  Format summary table (derived from original)
printOverallResTable(outStr,cfgName);
% %% Plot velocities

% %% Plot flowrates
ff = flowRatesCompPlot(outStr,cfgName);

%% Plot angles (?)

%% DECLARATIONS/sandbox

function resStruct = produceResults(outStr)
% TO-DO: get angle at WH (make sure it agrees with table)

% Total flow rate/side
Qtot = [sum(outStr.L.Q(:,1)) sum(outStr.R.Q(:,1))];
resStruct.Qtot = Qtot;

% Index of z corresp. to WH (saving it)
WHindex = find(outStr.L.z >= outStr.params(1)*10,1,'first');
resStruct.WHindex = WHindex;

% Q usable up to WH
% keep the vector for other calcs
Q_Usable2wh = [outStr.L.Q(1:WHindex,2) outStr.R.Q(1:WHindex,2)];
Q_Usable2hw_tot = sum(Q_Usable2wh,1);
resStruct.Q_Usable2hw_tot = Q_Usable2hw_tot;
resStruct.Q_Usable2hw_perc = Q_Usable2hw_tot./Qtot.*100;

% Q NON-usable up to WH
Q_NonUsable2wh = [outStr.L.Q(1:WHindex,1) outStr.R.Q(1:WHindex,1)];
Q_NonUsable2hw_tot = sum(Q_NonUsable2wh,1)-Q_Usable2hw_tot;
resStruct.Q_NonUsable2hw_tot = Q_NonUsable2hw_tot;
resStruct.Q_NonUsable2hw_perc = Q_NonUsable2hw_tot./Qtot.*100;

% potentially usable/nonusable up to WH + 0.5 m
Q_PotUsableOverWH = [outStr.L.Q(WHindex+1:WHindex+5,2) outStr.R.Q(WHindex+1:WHindex+5,2)];
Q_PotUsableOverWH_tot = sum(Q_PotUsableOverWH,1);
resStruct.Q_PotUsableOverWH_perc = Q_PotUsableOverWH_tot./Qtot.*100;
resStruct.Q_PotUsableOverWH_tot = Q_PotUsableOverWH_tot;

Q_NonUsableOverWH = [outStr.L.Q(WHindex+1:WHindex+5,1) outStr.R.Q(WHindex+1:WHindex+5,1)];
Q_NonUsableOverWH_tot = sum(Q_NonUsableOverWH,1);
resStruct.Q_NonUsableOverWH_perc = Q_NonUsableOverWH_tot./Qtot.*100;
resStruct.Q_NonUsableOverWH_tot = Q_NonUsableOverWH_tot;

% potentially usable/nonusable above WH + 0.5 m
Q_PotUsable2hihg = [outStr.L.Q(WHindex+6:end,2) outStr.R.Q(WHindex+6:end,2)];
Q_PotUsable2hihg_tot = sum(Q_PotUsable2hihg,1);
resStruct.Q_PotUsable2hihg_perc = Q_PotUsable2hihg_tot./Qtot.*100;
resStruct.Q_PotUsable2hihg_tot = Q_PotUsable2hihg_tot;

Q_NonUsable2hihg = [outStr.L.Q(WHindex+6:end,1) outStr.R.Q(WHindex+6:end,1)];
Q_NonUsable2hihg_tot = sum(Q_NonUsable2hihg,1);
resStruct.Q_NonUsable2hihg_perc = (Q_NonUsable2hihg_tot)./Qtot.*100;
resStruct.Q_NonUsable2hihg_tot = Q_NonUsable2hihg_tot;

% Mean, std, cv of usable: the original system gets the mean of the non-zero elements
Q_Us_muStd = [ mean( Q_Usable2wh( Q_Usable2wh(:,1) ~= 0 , 1) ) mean( Q_Usable2wh( Q_Usable2wh(:,2) ~= 0 , 2) ) ;
    std( Q_Usable2wh( Q_Usable2wh(:,1) ~= 0 , 1) ) std( Q_Usable2wh( Q_Usable2wh(:,2) ~= 0 , 2) ) ];
% Computing CV directly while saving
resStruct.Q_Us_muStdCV = [Q_Us_muStd; Q_Us_muStd(2,:)./Q_Us_muStd(1,:).*100];

% Outliers: the original system COUNTS the amount of data points outside of p/m 25%. That sucks, so I'll count the total flow rate
for side = 1:2
Idx = [find(  Q_Usable2wh(:,side) > 1.25*Q_Us_muStd(1,side) ); 
    find( Q_Usable2wh(:,side) < 0.75*Q_Us_muStd(1,side) )];
Qbuffer(side) = sum( Q_Usable2wh(Idx,side) );
end
resStruct.Q_outliers = Qbuffer./Q_Usable2hw_tot.*100;

disp('Processing done');
end

function fig = flowRatesCompPlot(outStr,cfgName)
% Comparative plots. input: L, R in this order
totalColour = [0.93,0.69,0.13];   % colours def
usableColour = [0.39,0.83,0.07];
potUsableColour = [0.85,0.33,0.10];

% Pre-calculating width of figure(s)
xmax = max([outStr.L.Q(:,1); outStr.R.Q(:,1)]);
% Index for highest volume recorded
hmax = max( find( outStr.L.Q(:,1) == 0,1,'first'), find( outStr.R.Q(:,1) == 0,1,'first') );

fig = figure;
ax1 = subplot(1,2,1);  % left side
% Plot total volume
barh(outStr.L.z,-outStr.L.Q(:,1),'FaceColor',totalColour,'FaceAlpha',0.7)
hold on
% Plot usable volume
barh(outStr.L.z(1:outStr.results.WHindex),-outStr.L.Q(1:outStr.results.WHindex,2),'FaceColor',usableColour,'FaceAlpha',0.7)
barh(outStr.L.z(outStr.results.WHindex+1:end),-outStr.L.Q(outStr.results.WHindex+1:end,2),'FaceColor',potUsableColour,'FaceAlpha',0.7)
plot(-outStr.results.Q_Us_muStdCV(1,1).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
grid minor
title('Left side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')
% set(gca,'XLim',1.1*[-xmax 0]);   % Restrict x field
plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
xticklabels(abs(xticks))

ax2 = subplot(1,2,2);  % right side
barh(outStr.R.z,outStr.R.Q(:,1),'FaceColor',totalColour,'FaceAlpha',0.7)
hold on
set(gca,'YAxisLocation','right')
% Plot usable volume
barh(outStr.R.z(1:outStr.results.WHindex),outStr.R.Q(1:outStr.results.WHindex,2),'FaceColor',usableColour,'FaceAlpha',0.7)
barh(outStr.R.z(outStr.results.WHindex+1:end),outStr.R.Q(outStr.results.WHindex+1:end,2),'FaceColor',potUsableColour,'FaceAlpha',0.7)
plot(outStr.results.Q_Us_muStdCV(1,2).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
grid minor
title('Right side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')

set(gca,'XLim',1.1*[0 xmax]);   % Restrict x field
plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)

linkaxes([ax1, ax2], 'y');
set(gca,"YLim",[180 outStr.L.z(hmax+3)]);

legend('Non-usable volume','Usable volume','Potentially usable volume','Working height')

set(gcf,'Position',[962    42   958   954])
saveas(fig,['figs/' cfgName '_Q'],'png')
saveas(fig,['figs/' cfgName '_Q'],'fig')
end
