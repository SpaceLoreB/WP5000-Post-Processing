%% Working parameters & defs.
h_w = 210;    % work height [cm]
vmin_usable = 2.6;   % usable air speed [m/s]
procMethod = 'x';
sideNames = ["L", "R"]';
nSides = 2;
%%
% [dname, dpath] = uigetfile({'*.csv','CSV Files (.csv)'},['Select file for side #']);
% inStr = rawData2componentArray( importWPcsv([dpath '\' dname], [2, Inf]) );
% 
inStr.(sideNames(1)) = raf4_040;
inStr.(sideNames(2)) = raf4_041;
%%
cfgName = input('Enter configuration name: ','s');  % I've learnt the hard way that I shouldn't overwrite variables.

outStr = struct('params',[h_w vmin_usable],'method',procMethod,'nSides',nSides,'sideNames',sideNames);    % no real need to carry over h_w right now, only doing it for safety
testName = sprintf('%s_%s_%i_%.0f',cfgName,outStr.method,outStr.params);
disp(testName);
%% PROCESS
for j = 1:nSides
    outStr.(sideNames(j)) = processSide(inStr.(sideNames(j)).velComponents);
    outStr.(sideNames(j)).z = inStr.(sideNames(j)).localZ;
    % If you have to replicate for a single side:
    % outStr.(sideNames(j)) = processSide(inStr.velComponents);
    % outStr.(sideNames(j)).z = inStr.localZ;
end

outStr.results = produceResults2(outStr);
% %%
% Keep working through the same cfg, then save it with chosen name at
% last (and export to storable file)
assignin("base",testName,outStr)
% save([testName char(datetime('today','Format','yyyy_MM_dd'))],testName);
% clear outStr

%  Format summary table (derived from original)
% printOverallResTable_DE(outStr,testName);

% %% Plot flowrates
fq = flowRatesCompPlot2(outStr,testName);
fv = vMaxCompPlot2(outStr,testName);

%% 2025_10_31 zeus cane
fq = flowRatesCompPlot2(F1_x_350_3,testName);
set(gca,'YLim',[200 4700]);
fv = vMaxCompPlot2(F1_x_350_3,testName);
set(gca,'YLim',[200 4700])
%% saveas
saveas(fq,['figs/' testName '_Q'],'epsc')
saveas(fq,['figs/' testName '_Q'],'fig')
saveas(fv,['figs/' testName '_V'],'epsc')
saveas(fv,['figs/' testName '_V'],'fig')
%% FUNCTION DECLARATIONS 

function fig = flowRatesCompPlot2(outStr,testName)
% Comparative plots. input: L, R in this order
totalColour = [0.93,0.69,0.13];   % colours def
usableColour = [0,123, 228]./255;
potUsableColour = [0.85,0.33,0.10];
fSize = 24;

% Pre-calculating width of figure(s)
xmax = max([outStr.L.Q(:,1); outStr.R.Q(:,1)]);
% Index for highest volume recorded
hmax = max( find( outStr.L.Q(:,1) == 0,1,'first'), find( outStr.R.Q(:,1) == 0,1,'first') );

fig = figure;
ax1 = subplot(1,2,1);  % left side
    % Plot total volume
    flowRatesPlot(outStr.L,'L')
    set(gca,'YAxisLocation','left')
    title('Left side',FontSize=fSize)
    set(gca,'XLim',1.1*[-xmax 0]);   % Restrict x field
    plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
    xticklabels(abs(xticks))
ax2 = subplot(1,2,2);  % right side
    flowRatesPlot(outStr.R,'R')
    title('Right side',FontSize=fSize)
    % xlabel('Air flow rate [m^3 h^{-1}]',FontSize=fSize)
    % ylabel('Height [mm]',FontSize=fSize)
    set(gca,'XLim',1.1*[0 xmax]);   % Restrict x field
    set(gca,'YAxisLocation','right')
    plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
linkaxes([ax1, ax2], 'y');
% set(gca,"YLim",[180 outStr.L.z(hmax+3)]);

legend('Non-usable volume','Usable volume','Potentially usable volume','25% from mean','','Working height','Location','north','FontSize',fSize-4)

set(gcf,'Position',[658 133 958 792])
% saveas(fig,['figs/' testName '_Q'],'png')
% saveas(fig,['figs/' testName '_Q'],'fig')
end

function flowRatesPlot(strToPlot,side)
    % give it a structure to plot and tell it if it's left or right (specify 'L' or 'R')
    fSize = 18;

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
    xlabel('Air flow rate [m^3 h^{-1}]',FontSize=fSize)
    ylabel('Height [mm]',FontSize=fSize)
end