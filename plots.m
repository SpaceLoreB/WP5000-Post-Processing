%% Comparative plots
% f1 = WPcompPlot(C1L,C1R,h_w,'C1');
% f1 = WPcompPlot(C2L,C2R,h_w,'C2');
f3 = WPcompPlot(S4C3,S4C3,h_w,'C3H');

%% Plotting
% b = rawBar3(rawVelocities);
% b = rawBar3(v_cutoff);
% b = rawBar3(strNabs);
% [ff, b] = rawBar3(v_usable);
% rawBarCompare(rawVelocitiesR,rawVelocitiesL)
% [ff, b] = rawBar3(Rafal_C1_raw.S4.velComponents(:,:,1));
% [ff, b] = rawBar3(inStr.velComponents(:,:,1))
rawBar3(v_valid(:,:,1))
function rawBarCompare(array1,array2)
figure
subplot(1,2,1)
    b1 = bar3(array1);
    title(sprintf('%s',inputname(1)))
    newTicksX = (xticks-1)*1e2 + evalin('base','startX');
    xticklabels(newTicksX)
    xlabel('Y [mm]')
    newTicksY = (yticks-1)*1e2 + evalin('base','startZ');
    yticklabels(newTicksY)
    ylabel('Z [mm]')
    zlabel('v_x [m s^{-1}]')
subplot(1,2,2)
    b2 = bar3(array2);
    title(sprintf('%s',inputname(2)))
    newTicksX = (xticks-1)*1e2 + evalin('base','startX');
    xticklabels(newTicksX)
    xlabel('Y [mm]')
    newTicksY = (yticks-1)*1e2 + evalin('base','startZ');
    yticklabels(newTicksY)
    ylabel('Z [mm]')
    zlabel('v_x [m s^{-1}]')
for k = 1:length(b1)
zdata = b1(k).ZData;
b1(k).CData = zdata;
b1(k).FaceColor = 'flat';
end
for k = 1:length(b2)
zdata = b2(k).ZData;
b2(k).CData = zdata;
b2(k).FaceColor = 'flat';
end

end

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
newTicksY = (yticks-1)*1e2 + evalin('base','startZ');
yticklabels(newTicksY)
ylabel('Z [mm]')
zlabel('v_x [m s^{-1}]')
end