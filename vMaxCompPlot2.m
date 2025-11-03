function fig = vMaxCompPlot2(outStr,testName)
% Comparative plots. input: L, R in this order
fSize = 24;

% Pre-calculating width of figure(s)
xmax = max([outStr.L.vMax; outStr.R.vMax]);
% Index for highest volume recorded
% hmax = max( find( outStr.L.vMax == 0,1,'first'), find( outStr.R.vMax == 0,1,'first') );

fig = figure;
ax1 = subplot(1,2,1);  % left side
    % Plot total volume
    vMaxPlot(outStr.L,'L')
    set(gca,'YAxisLocation','left')
    title('Left side',FontSize=fSize)
    set(gca,'XLim',1.1*[-xmax 0]);   % Restrict x field
    plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
    xticklabels(abs(xticks))
ax2 = subplot(1,2,2);  % right side
    vMaxPlot(outStr.R,'R')
    title('Right side',FontSize=fSize)
    % xlabel('Maximum air speed [m s^{-1}]')
    % ylabel('Height [mm]')
    set(gca,'XLim',1.1*[0 xmax]);   % Restrict x field
    set(gca,'YAxisLocation','right')
    plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
linkaxes([ax1, ax2], 'y');
% set(gca,"YLim",[180 outStr.L.z(hmax+3)]);

% set(gcf,'Position',[658 133 958 792])
% saveas(fig,['figs/' testName '_vMax'],'png')
% saveas(fig,['figs/' testName '_vMax'],'fig')
end

function vMaxPlot(strToPlot,side)
    % give it a structure to plot and tell it if it's left or right (specify 'L' or 'R')
    vMaxColour = [.49, .18, .56];
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

    % % PLOTTING
    barh(strToPlot.z,sideCoef*strToPlot.vMax,'FaceColor',vMaxColour,'FaceAlpha',0.7,'BarWidth',1)
    hold on
    grid minor
    xlabel('Maximum air speed [m s^{-1}]',FontSize=fSize)
    ylabel('Height [mm]',FontSize=fSize)
end