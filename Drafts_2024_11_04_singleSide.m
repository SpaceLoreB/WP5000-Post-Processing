%% INPUT
% Decide where you want to work from
workPath = 'C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing';
dpath = uigetdir;
%% Start of input
% % how many sides
nSides = 1;
h_w = 500;    % work height [cm]
vmin_usable = 0;   % usable air speed [m/s]
procMethod = 'abs';
%%
cd(dpath);
dname = uigetfile({'*.csv','CSV Files (.csv)'},['Select file for side #']);
% [dname, dpath] = uigetfile({'*.csv','CSV Files (.csv)'},['Select file for side #']);
cd(workPath);
cfgName = input('Enter configuration name: ','s');  % I've learnt the hard way that I shouldn't overwrite variables.

% prepare input structure
inStr = rawData2componentArray( importWPcsv([dpath '\' dname], [2, Inf]) );

% %% statistiche
[v_valid, v_absolute, I,J] = validate_Velocities(inStr.velComponents, 1);

% %% Usual processing
outStr = processSide(v_valid);
outStr.z = inStr.localZ;
outStr.stats = velocity_Stats(v_absolute);

muStd = [ mean( outStr.Q( outStr.Q(:,1) ~= 0 , 1) ); std( outStr.Q( outStr.Q(:,1) ~= 0 , 1) ) ];
outStr.muStdCV = [muStd; muStd(2)./muStd(1).*100];
% %% save
assignin('base',cfgName,outStr);
disp(outStr)
%% Stats of velocities
% plotCSD(storm_w300_a1,storm_w300_a3,storm_w300_a5)
% plotCSD(r1,r2,r3);
flowRatesPlot_Multi(r1,r2,r3);
%%
plotCSD(storm_w300_a1,storm_w405_a1,storm_w540_a1);
%%
% flowRatesPlot_Multi(storm_w300_a1,storm_w300_a3,storm_w300_a5);
%%
flowRatesPlot_Multi(storm_w300_a1,storm_w405_a1,storm_w540_a1);
%% FCN DECL
function sideStr = rawData2componentArray(rawData,side)
    if nargin > 1
        % t.d: check that side is a char/categorical
        rawData = rawData(rawData.side == side,:);   % only taking the results from one side. No idea why I called it "impN" in the first place.
    end
    % For L-R configs: which field is larger? adapt to that one
    startX = min(rawData.px);
    startZ = min(rawData.py);  % The system calls it y, but globally would be a z (vertical). Correcting this for clarity
    nX = (max(rawData.px) - startX)/1e2 + 1; % number of x steps
    nZ = (max(rawData.py) - startZ)/1e2 + 1; % number of z steps
    velComponents = zeros(nZ,nX,3);  % 3D array containing the field of velocity components
    
    sideStr.localZ = (startZ/100 : 2+nZ).*100;  % heights vector
    
    for j = 1:height(rawData)
        idX = (rawData.px(j) - startX)/1e2 + 1;
        idZ = (rawData.py(j) - startZ)/1e2 + 1;
        velComponents(idZ,idX,1:3) = table2array(rawData(j,4:6));
    end
    sideStr.velComponents = velComponents;
end

function flowRatesPlot_Multi(varargin)
colours = .66.*[
    0    0.4805    0.8906;
    0.9258    0.1992    0.1016;
    0.3922    0.4902    0.5686;   % info
    0.1020    0.5490    0.3922; % green, ex NaTec
    rand(nargin-3,3)];    % Further colours are randomised

fig = figure;
for j = 1:nargin
    ax(j) = subplot(1,nargin,j);  % left side
    hold on
    for i = 1:nargin
        if i ~= j
            barh(varargin{i}.z,varargin{i}.Q(:,1),'FaceColor',[.8 .8 .8],'FaceAlpha',0.5);
        end
    end
    barh(varargin{j}.z,varargin{j}.Q(:,1),'FaceColor',colours(j,:),'FaceAlpha',0.5);

    grid minor
    title('\alpha = []')
    % title('\omega = _ [min^{-1}]')
    xlabel('Air flow rate [m^3 h^{-1}]')
    ylabel('Height [mm]')
    % xlim([0 1500])
    plot(varargin{j}.muStdCV(1).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
end

linkaxes(ax, 'y')
% 
% set(gcf,'Position',[1 41 1920 963])
% saveas(fig,['figs/' cfgName '_Q'],'png')
% saveas(fig,['figs/' cfgName '_Q'],'fig')
% 
end

function newHistogram(varargin)
% % Custom histogram plotting function. Shows pre-binned data from translateTab and cumulative percentages of each droplet class.
% Usage:
%   NEWHISTOGRAM(structin)

colours = .66.*[
    0    0.4805    0.8906;
    0.9258    0.1992    0.1016;
    0.3922    0.4902    0.5686;
    rand(nargin-3,3)];    % Further colours are randomised

nOpen = length(findobj('type','figure'));

figure(nOpen+1)
% subplot(1,2,1)
yyaxis left
for j = 1:nargin
    histogram('BinEdges',varargin{j}.stats.binEdges,'BinCounts',varargin{j}.stats.cumCount,'FaceColor',colours(j,:))
    hold on
end
    ylabel('Drop Size Distribution - % counted')%,'FontSize',fs)
    set(gca,'XScale',"log")
    set(gca,'XTick',xT)

yyaxis right
for j = 1:nargin
    plot(varargin{j}.binCentres, varargin{j}.cumCount,'-','LineWidth',2,'Color',colours(j,:))
    hold on
end
    ylabel('Number Cumulative Distribution [%]')%,'FontSize',fs)
    grid on
xlabel('Droplet Diameter [\mum]')%,'FontSize',fs)
title('Numeric DSD');

end

function [ax,colours] = stackedHistogram(varargin)
% % I made this for txc
% % Custom histogram plotting function. Shows pre-binned data from makeStats
% and cumulative percentages of each droplet class.
% Usage:
%   STACKEDHIST(structin)

colours = .66.*[
    0    0.4805    0.8906;
    0.9258    0.1992    0.1016;
    0.3922    0.4902    0.5686;
    rand(nargin-3,3)];    % Further colours are randomised

nOpen = length(findobj('type','figure'));

figure(nOpen+1)
p = [1,3,5];
tits = ["Test A", "Test B", "Test C"];

for j = 1:3
    ax(j) = subplot(3,2,p(j));
    histogram('BinEdges',varargin{j}.binEdges,'BinCounts',varargin{j}.percCount,'FaceColor',colours(j,:))
    ylabel('% num')
    xlabel('Droplet Diameter [\mum]')
    title(tits(j))
    grid on
    ax(j+3) = subplot(3,2,p(j)+1);
    histogram('BinEdges',varargin{j}.binEdges,'BinCounts',varargin{j}.percVol,'FaceColor',colours(j,:))
    ylabel('% vol')
    xlabel('Droplet Diameter [\mum]')
    title(tits(j))
    grid on
end

linkaxes([ax(1),ax(2),ax(3)],'x')
linkaxes([ax(4),ax(5),ax(6)],'x')

end

function plotCSD(varargin)

colours = .66.*[
    0    0.4805    0.8906;
    0.9258    0.1992    0.1016;
    0.3922    0.4902    0.5686;   % info
    0.1020    0.5490    0.3922; % green, ex NaTec
    rand(nargin-3,3)];    % Further colours are randomised

nOpen = length(findobj('type','figure'));

figure(nOpen+1)
for j = 1:nargin
    plot(varargin{j}.stats.binCentres, varargin{j}.stats.cumCount,'-','LineWidth',2,'Color',colours(j,:))
    hold on
    % plot(varargin{j}.dVxx,[10 50 90]./100,'o','Color',colours(j,:),'HandleVisibility','off','LineWidth',1,'MarkerSize',8)
end
    ylabel('Velocities Cumulative Distribution [%]')%,'FontSize',fs)
grid minor
xlabel('Velocity [m s^{-1}]')%,'FontSize',fs)
% lgd = legend('\alpha = 1','\alpha = 3','\alpha = 5')
% lgd = legend('300 min^{-1}','420 min^{-1}','540 min^{-1}');
% lgd.FontSize = 18;
% lgd.Location = 'northwest'
end
