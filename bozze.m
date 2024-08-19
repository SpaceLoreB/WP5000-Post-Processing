%% MERDA ATTUALE 07.08
velColour = 'b';
xmax = max([outStr.L.vMax; outStr.R.vMax]);
% Index for highest volume recorded
hmax = max( find( outStr.L.vMax == 0,1,'first'), find( outStr.R.vMax == 0,1,'first') );

% Plot max speeds per height
fig = figure;
ax1 = subplot(1,2,1);  % left side
barh(outStr.L.z,-outStr.L.vMax,'FaceColor',velColour,'FaceAlpha',0.7)
hold on
% Plot usable volume
plot(-mean(outStr.L.vMax(outStr.L.vMax ~= 0)).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
grid minor
title('Left side')
xlabel('Maximum recorded air velocity [m s^{-1}]')
ylabel('Height [mm]')
set(gca,'XLim',1.1*[-xmax 0]);   % Restrict x field
plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)
xticklabels(abs(xticks))

ax2 = subplot(1,2,2);  % right side
barh(outStr.R.z,outStr.R.vMax,'FaceColor',velColour,'FaceAlpha',0.7)
hold on
set(gca,'YAxisLocation','right')
% Plot usable volume
plot(mean(outStr.R.vMax(outStr.R.vMax ~= 0)).*[1.25 0.75; 1.25 0.75],ylim,'k--','HandleVisibility','off')
grid minor
title('Right side')
xlabel('Maximum recorded air velocity [m s^{-1}]')
ylabel('Height [mm]')
set(gca,'XLim',1.1*[0 xmax]);   % Restrict x field 
plot(xlim,outStr.params(1).*[1 1].*10,'Color','r','LineWidth',1.5)

linkaxes([ax1, ax2], 'y');
set(gca,"YLim",[180 outStr.L.z(hmax+3)]);

%% plotting angles
% Define the grid
y = outStr.R.z(1:hmax+3);
x = zeros(hmax+3,1);

% Define the vector components
al = outStr.R.alpha(1:hmax+3);
L = 0.5;
u = L*cos(al);
v = L*sin(al);

% Plot the vector field
figure;
quiver(x, y, u, v, 'MaxHeadSize', .5);
title('Vector Field');
xlabel('X');
ylabel('Y');
axis equal;