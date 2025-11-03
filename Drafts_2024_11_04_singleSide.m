%% INPUT
% Decide where you want to work from
workPath = 'C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing';
dpath = uigetdir;
%% Start of input
% % how many sides
nSides = 1;
h_w = 200;    % work height [cm]
vmin_usable = 2.6;   % usable air speed [m/s]
procMethod = 'x'; % 'abs'; 'x'; 'xz'
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
% outStr.results = produceResults2(outStr);

muStd = [ mean( outStr.Q( outStr.Q(:,1) ~= 0 , 1) ); std( outStr.Q( outStr.Q(:,1) ~= 0 , 1) ) ];
outStr.muStdCV = [muStd; muStd(2)./muStd(1).*100];
% %% save
assignin('base',cfgName,outStr);
disp(dname)
disp(outStr)

%% Stats of velocities
% plotCSD(storm_w300_a1,storm_w300_a3,storm_w300_a5)
% plotCSD(r1,r2,r3);
% flowRatesPlot_Multi(rep_060,rep_061,rep_062,rep_063);
% flowRatesPlot_Multi(d25,d50,d75);

%%
flowRatesPlot(raf4_041,1);
%% FCN DECL

function flowRatesPlot(strToPlot,sideCoef)
    totalColour = [0.93,0.69,0.13];   % colours def
    usableColour = [0,123, 228]./255;
    potUsableColour = [0.85,0.33,0.10];
    WHindex = find(strToPlot.z >= evalin('base','h_w')*10,1,'first');
    % give it a structure to plot and tell it if it's left or right (specify -1 for 'L' or 1 for 'R')
    % Probably inefficient as fuck, but still
    % Cedrata Tassoni
    % results = evalin('caller',[inputname(1) '.results']);
    % % PLOTTING
    barh(strToPlot.z,sideCoef*strToPlot.Q(:,1),'FaceColor',totalColour,'FaceAlpha',0.7,'BarWidth',1)
    hold on
    % % Plot usable volume
    barh(strToPlot.z(1:WHindex),sideCoef*strToPlot.Q(1:WHindex,2),'FaceColor',usableColour,'FaceAlpha',0.7,'BarWidth',1)
    barh(strToPlot.z(WHindex+1:end),sideCoef*strToPlot.Q(WHindex+1:end,2),'FaceColor',potUsableColour,'FaceAlpha',0.7,'BarWidth',1)
    plot(sideCoef*strToPlot.muStdCV(1).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
    grid minor
    xlabel('Air flow rate [m^3 h^{-1}]')
    ylabel('Height [mm]')

    % % Pre-calculating width of figure(s)
    if sideCoef == -1
        set(gca,'YAxisLocation','left')
    end
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
