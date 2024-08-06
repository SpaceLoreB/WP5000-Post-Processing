%% INPUT
% Import file(s)
% UI for selection
[dname dpath] = uigetfile({'*.csv','CSV Files (.csv)'},'Select file');
rawData = importWPcsv([dpath dname], [2, Inf]);
% Create structure
% % variable name
cfgName = input('Enter configuration name: ','s');

%% Working parameters
h_w = 180;    % work height [cm]
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
%% PROCESS, STORE
outStr.L = processSide(rawData,'L');
outStr.R = processSide(rawData,'R');

%% Calculating results table
outStr.results = produceResults(outStr);

% Keep working through the same cfg, then save it with chosen name at
% last (and export to storable file)
% assignin("base",cfgName,outStr)
% clear outStr

% % % Pretty much the end of the processing. Now produce some readable and
% (hopefully) usable output

%% COMPARE, PLOT, SAVE
%% Format ISO-compl. tables
% (usable, up to w_h --> bicolor?)
% makeResTable(outStr,cfgName);

%%  Format summary table (as per original)
printOverallResTable(outStr,cfgName);
%% Plot velocities

%% Plot flowrates
% WPcompPlot
%% Plot angles (?)

% % % TEMPORARY: OLD PLOT FOR COMPARISON
% Comparative plots. input: L, R in this order
green = [0.47 0.67 0.19];   % colours def
blue = [0.07 0.62 1];

fig = figure;
% subplot(1,2,1)  % left side
barh(outStr.L.z,-outStr.L.Q(:,1),'FaceColor',green,'FaceAlpha',0.7)
hold on
barh(outStr.L.z,-outStr.L.Q(:,2),'FaceColor',blue,'FaceAlpha',0.7)
grid on
xticklabels(-xticks)
title('Left side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')
plot(-[mu*1.25 0.75*mu; mu*1.25 0.75*mu],ylim,'k--')

plot(-[C3L.muStd(1)*1.25 0.75*C3L.muStd(1); C3L.muStd(1)*1.25 0.75*C3L.muStd(1)],ylim,'k--')
plot(xlim,[h_w h_w].*10,'Color','r','LineWidth',1.5)

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

end

% might eventually move to separate file
% to do:
% - plot means pm std
% - change xlims to fit 1.1*max q_tot
% - try out other fcn
% - change colours

function fig = flowRatesCompPlot(outStr)
% Comparative plots. input: L, R in this order
totalColour = [0.93,0.69,0.13];   % colours def
usableColour = [0.39,0.83,0.07];
potUsableColour = [0.85,0.33,0.10];

fig = figure;
subplot(1,2,1)  % left side
% Plot total volume
barh(outStr.L.z,-outStr.L.Q(:,1),'FaceColor',totalColour,'FaceAlpha',0.7)
hold on
% Plot usable volume
barh(outStr.L.z(1:k),-outStr.L.Q(1:k,2),'FaceColor',usableColour,'FaceAlpha',0.7)
barh(outStr.L.z(k+1:end),-outStr.L.Q(k+1:end,2),'FaceColor',potUsableColour,'FaceAlpha',0.7)
grid on
xticklabels(-xticks)
title('Left side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')
% plot(-[outStr.muStd(1)*1.25 0.75*outStr.muStd(1); outStr.muStd(1)*1.25 0.75*outStr.muStd(1)],ylim,'k--')
plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)

subplot(1,2,2)  % right side
barh(outStr.R.z,outStr.R.Q(:,1),'FaceColor',totalColour,'FaceAlpha',0.7)
hold on
set(gca,'YAxisLocation','right')
% Plot usable volume
barh(outStr.R.z(1:k),outStr.R.Q(1:k,2),'FaceColor',usableColour,'FaceAlpha',0.7)
barh(outStr.R.z(k+1:end),outStr.R.Q(k+1:end,2),'FaceColor',potUsableColour,'FaceAlpha',0.7)
grid on
% plot([C3R.muStd(1)*1.25 0.75*C3R.muStd(1); C3R.muStd(1)*1.25 0.75*C3R.muStd(1)],ylim,'k--')
plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
legend('Non-usable volume','Usable volume','Potentially usable volume','Working height')
title('Right side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')

% set(gcf,'Position',[680 105 790 773])
% saveas(fig,strcat('figs/',savename),'png')
% saveas(fig,strcat('figs/',savename),'fig')
end

% ALTERNATIVE
function nzPlot(outStr)
figure
hold on

% y = 1:length(L);    %defining heigth of plot
% hPatt = evalin('base','hPatt');
% hPt = hPatt(1:2:end); 
barh(outStr.L.z,[-outStr.L.Q(:,1) outStr.R.Q(:,1)],'stacked','FaceColor',green,'FaceAlpha',0.5,'BarWidth',.5);
barh(outStr.L.z,[-outStr.L.Q(:,2) outStr.R.Q(:,2)],'stacked','FaceColor',blue,'FaceAlpha',0.5,'BarWidth',.5);
% errorbar(-L(:,1),y,L(:,2),'horizontal','LineStyle','none','Color',colour,'CapSize',9,'LineWidth',1)
% errorbar(R(:,1),y,R(:,2),'horizontal','LineStyle','none','Color',colour,'CapSize',9)
grid on

% Improve readability
plot([0 0],ylim,'k','LineWidth',2)    % Plotting a black centreline
newXLim = 1.05*[-ceil(max( outStr.L.Q(:,1) )) ceil(max( outStr.R.Q(:,1) ))];
set(gca,'XLim',newXLim);   % Restrict x field
set(gca,'XTickLabel',abs(xticks))   % This makes the x ticks symmetrical

plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
legend('Non-usable Volume','Usable Volume','Working Height')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')

set(gcf,'Position',[770 42 766 738]);

% legend([aa,bb(1)],'Media ugelli (lato) +/- 10%','Media dei lati +/- 5%','Location','north','FontSize',14);
% + Add title, subtitle with symmetry
title('Distribuzione portate volumetriche');
end