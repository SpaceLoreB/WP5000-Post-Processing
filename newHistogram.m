function newHistogram(varargin)
% % Custom histogram plotting function. Shows pre-binned data from translateTab and cumulative percentages of each droplet class.
% Usage:
%   NEWHISTOGRAM(structin)

colours = .66.*[
    0    0.4805    0.8906;
    0.9258    0.1992    0.1016;
    0.3922    0.4902    0.5686;
    rand(nargin-3,3)];    % Further colours are randomised

nOpen = length(findobj('type','figure'));

figure(nOpen+1)
% subplot(1,2,1)
yyaxis left
for j = 1:nargin
    histogram('BinEdges',varargin{j}.binEdges,'BinCounts',varargin{j}.count,'FaceColor',colours(j,:))
    hold on
end
    ylabel('Drop Size Distribution - % counted')%,'FontSize',fs)

yyaxis right
for j = 1:nargin
    plot(varargin{j}.binCentres, varargin{j}.cumCount,'-','LineWidth',2,'Color',colours(j,:))
    hold on
end
    ylabel('Number Cumulative Distribution [%]')%,'FontSize',fs)
    grid on
xlabel('Velocity [m s^{-1}]')%,'FontSize',fs)
title('Velocities');

end