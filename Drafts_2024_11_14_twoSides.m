%% Working parameters & defs.
h_w = 230;    % work height [cm]
vmin_usable = 3;   % usable air speed [m/s]
procMethod = 'x';
sideNames = ["L", "R"]';
nSides = 2;
%%
inStr.(sideNames(1)) = Rafal_C3_raw.S5;
inStr.(sideNames(2)) = Rafal_C3_raw.S6;
%%
cfgName = input('Enter configuration name: ','s');  % I've learnt the hard way that I shouldn't overwrite variables.

outStr = struct('params',[h_w vmin_usable],'method',procMethod,'nSides',nSides,'sideNames',sideNames);    % no real need to carry over h_w right now, only doing it for safety
testName = sprintf('%s_%s_%i_%.0f',cfgName,outStr.method,outStr.params);
disp(testName);
%% PROCESS
for j = 1:nSides
    outStr.(sideNames(j)) = processSide(inStr.(sideNames(j)).velComponents);
    outStr.(sideNames(j)).z = inStr.(sideNames(j)).localZ;
end

outStr.results = produceResults2(outStr);
% %%
% Keep working through the same cfg, then save it with chosen name at
% last (and export to storable file)
assignin("base",testName,outStr)
save([testName char(datetime('today','Format','yyyy_MM_dd'))],testName);
% clear outStr

%  Format summary table (derived from original)
printOverallResTable_DE(outStr,testName);

% %% Plot flowrates
ff = flowRatesCompPlot2(outStr,testName);

%% FUNCTION DECLARATIONS 
function resStruct = produceResults2(outStr)
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

% potentially usable/nonusable above WH + 0.5 m
Q_PotUsable2hihg = [outStr.L.Q(WHindex+1:end,2) outStr.R.Q(WHindex+1:end,2)];
Q_PotUsable2hihg_tot = sum(Q_PotUsable2hihg,1);
resStruct.Q_PotUsable2hihg_perc = Q_PotUsable2hihg_tot./Qtot.*100;
resStruct.Q_PotUsable2hihg_tot = Q_PotUsable2hihg_tot;

Q_NonUsable2hihg = [outStr.L.Q(WHindex+1:end,1) outStr.R.Q(WHindex+1:end,1)];
Q_NonUsable2hihg_tot = sum(Q_NonUsable2hihg,1);
resStruct.Q_NonUsable2hihg_perc = (Q_NonUsable2hihg_tot)./Qtot.*100;
resStruct.Q_NonUsable2hihg_tot = Q_NonUsable2hihg_tot;

% % FOLLOWING PART DOES NOT WORK IF INVESTIGATED AREA IS SMALL (i.e. arrays are not tall enough to check what's at 6 elements above working heigth)

% % potentially usable/nonusable up to WH + 0.5 m
% Q_PotUsableOverWH = [outStr.L.Q(WHindex+1:WHindex+5,2) outStr.R.Q(WHindex+1:WHindex+5,2)];
% Q_PotUsableOverWH_tot = sum(Q_PotUsableOverWH,1);
% resStruct.Q_PotUsableOverWH_perc = Q_PotUsableOverWH_tot./Qtot.*100;
% resStruct.Q_PotUsableOverWH_tot = Q_PotUsableOverWH_tot;
% 
% Q_NonUsableOverWH = [outStr.L.Q(WHindex+1:WHindex+5,1) outStr.R.Q(WHindex+1:WHindex+5,1)];
% Q_NonUsableOverWH_tot = sum(Q_NonUsableOverWH,1);
% resStruct.Q_NonUsableOverWH_perc = Q_NonUsableOverWH_tot./Qtot.*100;
% resStruct.Q_NonUsableOverWH_tot = Q_NonUsableOverWH_tot;
% 
% % potentially usable/nonusable above WH + 0.5 m
% Q_PotUsable2hihg = [outStr.L.Q(WHindex+6:end,2) outStr.R.Q(WHindex+6:end,2)];
% Q_PotUsable2hihg_tot = sum(Q_PotUsable2hihg,1);
% resStruct.Q_PotUsable2hihg_perc = Q_PotUsable2hihg_tot./Qtot.*100;
% resStruct.Q_PotUsable2hihg_tot = Q_PotUsable2hihg_tot;
% 
% Q_NonUsable2hihg = [outStr.L.Q(WHindex+6:end,1) outStr.R.Q(WHindex+6:end,1)];
% Q_NonUsable2hihg_tot = sum(Q_NonUsable2hihg,1);
% resStruct.Q_NonUsable2hihg_perc = (Q_NonUsable2hihg_tot)./Qtot.*100;
% resStruct.Q_NonUsable2hihg_tot = Q_NonUsable2hihg_tot;

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

function fig = flowRatesCompPlot2(outStr,testName)
% Comparative plots. input: L, R in this order
totalColour = [0.93,0.69,0.13];   % colours def
usableColour = [0,123, 228]./255;
potUsableColour = [0.85,0.33,0.10];

% Pre-calculating width of figure(s)
xmax = max([outStr.L.Q(:,1); outStr.R.Q(:,1)]);
% Index for highest volume recorded
hmax = max( find( outStr.L.Q(:,1) == 0,1,'first'), find( outStr.R.Q(:,1) == 0,1,'first') );

fig = figure;
ax1 = subplot(1,2,1);  % left side
    % Plot total volume
    flowRatesPlot(outStr.L,'L')
    set(gca,'YAxisLocation','left')
    title('Left side')
    set(gca,'XLim',1.1*[-xmax 0]);   % Restrict x field
    plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
    xticklabels(abs(xticks))
ax2 = subplot(1,2,2);  % right side
    flowRatesPlot(outStr.R,'R')
    title('Right side')
    xlabel('Air flow rate [m^3 h^{-1}]')
    ylabel('Height [mm]')
    set(gca,'XLim',1.1*[0 xmax]);   % Restrict x field
    set(gca,'YAxisLocation','right')
    plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
linkaxes([ax1, ax2], 'y');
% set(gca,"YLim",[180 outStr.L.z(hmax+3)]);

legend('Non-usable volume','Usable volume','Potentially usable volume','25% from mean','','Working height')

set(gcf,'Position',[658 133 958 792])
saveas(fig,['figs/' testName '_Q'],'png')
saveas(fig,['figs/' testName '_Q'],'fig')
end

function flowRatesPlot(strToPlot,side)
    % give it a structure to plot and tell it if it's left or right (specify 'L' or 'R')
    
    % Not really fond of this, but if it works...
    if side == 'L'
        sideCoef = -1;
    elseif side == 'R'
        sideCoef = 1;
    else
        disp('bro wtf')
        return
    end

    % Probably inefficient as fuck, but still
    % Cedrata Tassoni
    results = evalin('caller','outStr.results');
    % % PLOTTING
    barh(strToPlot.z,sideCoef*strToPlot.Q(:,1),'FaceColor',evalin('caller','totalColour'),'FaceAlpha',0.7,'BarWidth',1)
    hold on
    % % Plot usable volume
    barh(strToPlot.z(1:results.WHindex),sideCoef*strToPlot.Q(1:results.WHindex,2),'FaceColor',evalin('caller','usableColour'),'FaceAlpha',0.7,'BarWidth',1)
    barh(strToPlot.z(results.WHindex+1:end),sideCoef*strToPlot.Q(results.WHindex+1:end,2),'FaceColor',evalin('caller','potUsableColour'),'FaceAlpha',0.7,'BarWidth',1)
    plot(sideCoef*results.Q_Us_muStdCV(1,1).*[1.25 0.75; 1.25 0.75],ylim,'k--')%,'HandleVisibility','off')
    grid minor
    xlabel('Air flow rate [m^3 h^{-1}]')
    ylabel('Height [mm]')
end