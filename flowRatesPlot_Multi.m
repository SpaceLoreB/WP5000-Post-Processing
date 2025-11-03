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
            barh(varargin{i}.z,varargin{i}.Q(:,1),'FaceColor',[.8 .8 .8],'FaceAlpha',0.5,'BarWidth',1);
        end
    end
    barh(varargin{j}.z,varargin{j}.Q(:,1),'FaceColor',colours(j,:),'FaceAlpha',0.5,'BarWidth',1);

    grid minor
    % title('\alpha = []')
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
