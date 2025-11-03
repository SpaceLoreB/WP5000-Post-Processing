vMax = Rafal_23_27_x_230_2.R.vMax;

%% proviamo coi valori massimi
cv_vMax = cv(vMax)

%% valori massimi fino altezza lavoro
WH = 21;    % indice dell'ultimo elemento fino altezza lavoro
cv_vMax_WH = cv(vMax(1:WH))

%% Tutto il dataset (filtrato)
vProc = Rafal_027.velComponents(1:WH,:,1);  % Dataset grezzo fino a WH

f1 = rawBar3(vProc);

% Copiato da processSide per filtrare velocità sotto 1.5 m/s
v_cutoff = zeros(size(vProc)); % initialise matrix to apply filters (cut-off, maximum speed, ...)
i_cutoff = find(vProc>=1.5);    % fin index of all velocities > 1.5 m/s (cut-off)
v_cutoff(i_cutoff) = vProc(i_cutoff);
vProc = v_cutoff;
clear v_cutoff i_cutoff;

f2 = rawBar3(vProcF);

cv_grezzi = cv(reshape(vProcF,height(vProcF)*width(vProcF),1))

%% Tutto il dataset (senza escludere 0, filtrato)
    m = mean( vProcF );
    s = std( vProcF );
cv_grezzi = s/m*100

%% Tutto il dataset (senza escludere 0, NON filtrato)
    m = mean( vProc );
    s = std( vProc );
cv_grezzi = s/m*100

%% TUtto, esclusione 0, filtrati
cv_grezzi = cv(reshape(vProc,height(vProc)*width(vProc),1))

%% dichiarazioni
function coeffVar = cv(vector)
    m = mean( vector( vector ~= 0 , 1) );
    s = std( vector( vector ~= 0 , 1) );
    coeffVar = s/m*100;
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
xlabel('Y [mm]')
ylabel('Z [mm]')
zlabel('v_x [m s^{-1}]')
end