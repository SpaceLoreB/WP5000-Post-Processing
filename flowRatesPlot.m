function flowRatesPlot(inStr,sideName,sideCoef)
    % give it a structure to plot and tell it if it's left or right (specify -1 for 'L' or 1 for 'R')
    strToPlot = inStr.(sideName);
    % Probably inefficient as fuck, but still
    % Cedrata Tassoni
    results = evalin('caller',[inputname(1) '.results']);
    % % PLOTTING
    barh(strToPlot.z,sideCoef*strToPlot.Q(:,1),'FaceColor',evalin('caller','totalColour'),'FaceAlpha',0.7)
    hold on
    % % Plot usable volume
    barh(strToPlot.z(1:results.WHindex),sideCoef*strToPlot.Q(1:results.WHindex,2),'FaceColor',evalin('caller','usableColour'),'FaceAlpha',0.7)
    barh(strToPlot.z(results.WHindex+1:end),sideCoef*strToPlot.Q(results.WHindex+1:end,2),'FaceColor',evalin('caller','potUsableColour'),'FaceAlpha',0.7)
    plot(sideCoef*results.Q_Us_muStd_overall(1).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
    grid minor
    title(sideName)
    xlabel('Air flow rate [m^3 h^{-1}]')
    % ylabel('Height [mm]')

    % % Pre-calculating width of figure(s)
    if sideCoef == -1
        xLimits = [-results.xmax 0];
        ylabel('Height [mm]')
        set(gca,'YAxisLocation','left')
    else
        xLimits = [0 results.xmax];
        % set(gca,'YAxisLocation','right')
    end
    set(gca,'XLim',1.1*xLimits);   % Restrict x field
    xticklabels(abs(xticks))
end