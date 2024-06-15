function fig = WPcompPlot(C3L,C3R,h_w,savename)
% Comparative plots. input: L, R in this order
green = [0.47 0.67 0.19];   % colours def
blue = [0.07 0.62 1];

fig = figure;
subplot(1,2,1)  % left side
barh(C3L.y,-C3L.q_h,'FaceColor',green)
hold on
barh(C3L.y,-C3L.q_us,'FaceColor',blue)
grid on
xticklabels(-xticks)
title('Left side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')
plot(-[C3L.muStd(1)*1.25 0.75*C3L.muStd(1); C3L.muStd(1)*1.25 0.75*C3L.muStd(1)],ylim,'k--')
plot(xlim,[h_w h_w].*10,'Color','r','LineWidth',1.5)

subplot(1,2,2)  % right side
barh(C3R.y,C3R.q_h,'FaceColor',green)
hold on
set(gca,'YAxisLocation','right')
barh(C3R.y,C3R.q_us,'FaceColor',blue)
grid on
plot([C3R.muStd(1)*1.25 0.75*C3R.muStd(1); C3R.muStd(1)*1.25 0.75*C3R.muStd(1)],ylim,'k--')
plot(xlim,[h_w h_w].*10,'Color','r','LineWidth',1.5)
legend('Non-usable Volume','Usable Volume','Working Height')
title('Right side')
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')

set(gcf,'Position',[680 105 790 773])

saveas(fig,strcat('figs/',savename),'png')
saveas(fig,strcat('figs/',savename),'fig')
end