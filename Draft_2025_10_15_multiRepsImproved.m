%% Reload data
% This script was meant as an improvement of the previous for multi
% configs, adding evaluation of usable aspd. However, the processing of the
% data didn't calculate it so I put it off
load('Raf_newSpouts.mat')
Z = spoutA_1.z; % Get "universal" Z

%%
[spA_t, spA_u] = evalVariability(spoutA_all{:});
% quick note: it's working, but the data that I have don't distinguish
% airflow types (usable, non-)
%% Roba vecchia
% making "fake" configurations using the #1 and the average volumes.
% might as well average all teh rest, but in due time
spA = spoutA_1;
spA.Q = [spoutA_avg(:,1) spoutA_avg(:,2)];
cvA = std( spA.Q(:,1) )/mean( spA.Q(:,1) );
totA = sum(spA.Q(:,1)); 

spB = spoutB_1;
spB.Q = [spoutB_avg(:,1) spoutB_avg(:,1)];
cvB = std( spB.Q(:,1) )/mean( spB.Q(:,1) );
totB = sum(spB.Q(:,1));
%% plotti
flowRatesPlot_Multi(spB, spA)

%%-- 10.09.25 15:55 --%
Z = spoutA_1.z;
gA = plotVariability(spoutA_avg,Z)
gB = plotVariability(spoutB_avg,Z)