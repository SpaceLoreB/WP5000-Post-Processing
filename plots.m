%% Comparative plots
% f1 = WPcompPlot(C1L,C1R,h_w,'C1');
% f1 = WPcompPlot(C2L,C2R,h_w,'C2');
f3 = WPcompPlot(S4C3,S4C3,h_w,'C3H');

%% Plotting (1)
figure
v_h_max = max(strNvx,[],2);

area(y,q_h,'FaceAlpha',0.5,'FaceColor',[0.47 0.67 0.19]);   % total flow
hold on
grid minor
area(y,q_us,'FaceColor',[0.07 0.62 1]); % usable flow
plot([0 0; 4000 4000], [mu*1.25 0.75*mu; mu*1.25 0.75*mu],'k--')
plot([h_w h_w].*10,[0 2000],'Color','r','LineWidth',1.5)
bar(y,v_h_max*1e2,'BarWidth',0.2,'FaceColor',[0.72 0.27 1])
%% Plotting
% b = rawBar3(strNvx);
% b = rawBar3(v_cutoff);
% b = rawBar3(strNabs);
[ff, b] = rawBar3(v_usable);

function [ff, b] = rawBar3(inArray)
% % This function plots the raw or mid-process air velocities
ff = figure;
b = bar3(inArray);
% next lines come from matlab doc, are just to color bars according to
% value
for k = 1:length(b)
zdata = b(k).ZData;
b(k).CData = zdata;
b(k).FaceColor = 'flat';
end
set(gca,'Position',[0.2335 0.1100 0.6828 0.8150]);
view(45,30)

title(sprintf('%s',inputname(1)))
newTicksX = (xticks-1)*1e2 + evalin('base','startX');
xticklabels(newTicksX)
xlabel('Y [mm]')
newTicksY = (yticks-1)*1e2 + evalin('base','startY');
yticklabels(newTicksY)
ylabel('Z [mm]')
zlabel('v_x [m s^{-1}]')
end