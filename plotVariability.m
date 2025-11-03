function g = plotVariability(qm,Z)
% Still have to manually pass Z because I'm lazy
g = figure;
subplot(1,4,[1 3])
barh(Z, qm(:,1),'FaceAlpha',0.5,...
    'FaceColor',[0.93,0.69,0.13],...
    'BarWidth',1)
hold on
errorbar(qm(:,1),Z,qm(:,2),'horizontal',"o",'LineWidth',1.5,'Color',.66.*[0    0.4805    0.8906])
xl = get(gca,"XLim");
set(gca,"XLim",[0 xl(2)]);
xlabel('Air flow rate [m^3 h^{-1}]')
ylabel('Height [mm]')
title('XX spout type')
legend('Mean (\mu)','Std.Dev. (\sigma)')
grid minor

subplot(1,4,4)
b = barh(Z, qm(:,2)./qm(:,1).*100,'FaceColor',.66.*[0    0.4805    0.8906]);
xtips1 = b.YEndPoints + 0.3;
ytips1 = b.XEndPoints;
% labels1 = string(b.YData);
yticklabels({}); % Removes labels but keeps tick marks
labels1 = compose('%.1f%%',b.YData);
text(xtips1,ytips1,labels1,'VerticalAlignment','middle')
xlabel('\sigma/\mu [%]')
grid minor

set(findall(g, '-property', 'FontSize'), 'FontSize', 14);
end