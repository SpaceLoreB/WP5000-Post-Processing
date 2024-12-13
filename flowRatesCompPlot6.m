function fig = flowRatesCompPlot6(outStr,cfgName)
% Comparative plots. input: L, R in this order
totalColour = [0.93,0.69,0.13];   % colours def
usableColour = 0.66.*[0    0.4805    0.8906];
% usableColour = [0.39,0.83,0.07];
potUsableColour = [0.85,0.33,0.10];

% % % NEEDED AFTER - EDIT: MAYBE NOT ANYMORE
% % Index for highest volume recorded
% hmax = max( find( outStr.L.Q(:,1) == 0,1,'first'), find( outStr.R.Q(:,1) == 0,1,'first') );

fig = figure;
for i = 1:6
ax(i) = subplot(1,6,i);  % left side
    sideName = ['S' num2str(i)];
    sideCoeff = (-1)^rem(i,2);
    flowRatesPlot(outStr,sideName,sideCoeff)
    % plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
end

% legend('Non-usable volume','Usable volume','Potentially usable volume','Working height')
linkaxes(ax, 'y')
% set(gca,"YLim",[180 outStr.L.z(hmax+3)]); 
% 
set(gcf,'Position',[1 41 1920 963])
saveas(fig,['figs/' cfgName '_Q'],'png')
saveas(fig,['figs/' cfgName '_Q'],'fig')
end
