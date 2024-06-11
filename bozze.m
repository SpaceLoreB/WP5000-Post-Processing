impN = C3dH(C3dH.ma == 'VR',:);   % only taking the results from 'NL' test

startX = min(impN.px);
startY = min(impN.py);
nX = (max(impN.px) - startX)/1e2 + 1; % number of x steps
nY = (max(impN.py) - startY)/1e2 + 1; % number of y steps
strN = zeros(nY,nX,3);  % structure to store the data

y = (3:2+nY).*100;  % need this for plotting
%% import table into single array
for j = 1:height(impN)
    idX = (impN.px(j) - startX)/1e2 + 1;
    idY = (impN.py(j) - startY)/1e2 + 1;
    strN(idY,idX,1:3) = table2array(impN(j,4:6));
end

%% absolutes
strNabs = vecnorm(strN,2,3);    % 2-Norm of velocity vector
strNvx = strN(:,:,1);   % Vx component
%%
v_cutoff = zeros(size(strNvx)); % initialise matrix to apply filters (cut-off, maximum speed, ...)
i_cutoff = find(strNvx>=1.5);    % fin index of all velocities > 1.5 m/s (cut-off)
v_cutoff(i_cutoff) = strNvx(i_cutoff);  % copy elements indexed into new matrix

h_w = 400;    % work height [cm]
r_max = h_w/10-2;   % index of rows below h_w
vmin_usable = 4;   % usable air speed
v_usable = zeros(size(strNvx)); % as above, specifically for v_usable
i_usable = find(v_cutoff >= vmin_usable);
% croppig to h_w
[r_u, c_u] = ind2sub(size(strNvx),i_usable);
i_heigth = find(r_u<=r_max);
r_usable = r_u(i_heigth);
c_usable = c_u(i_heigth);

% this cycle checks that there are more than 2 measurements at each height
% with speed more than 4 m/s
for j = 1:max(r_u)
    cd = r_u == j;
    if sum(cd) < 2
        I = find(cd);
        r_usable(I) = [];
        c_usable(I) = [];
        fprintf('Removed row #%i\n',I)
    end
end
clear cd j I

i_usable = sub2ind(size(strNvx),r_usable,c_usable);
v_usable(i_usable) = v_cutoff(i_usable);  % copy elements indexed into new matrix

%% Volumes
% % PUT THIS STUFF INTO A STRUCT
% % for each height h, q(h) = sum_i(A*v(h,i)), where A = 1e-2 m^2, area of
% sampling point, and has to be corrected for 3.6e+3 s/h, since speed is in
% s/h and q referred to h.
q_h = sum(v_cutoff,2)*36;
q_tot = sum(q_h);

q_us = sum(v_usable,2)*36;
q_us_tot = sum(q_us);

q_us_tot/q_tot;
mu = mean(q_us(q_us ~= 0));
sgm = std(q_us(q_us ~= 0));
CV = sgm/mu;

%% Plotting (1)
figure
v_h = max(strNvx,[],2);

area(y,q_h,'FaceAlpha',0.5,'FaceColor',[0.47 0.67 0.19]);   % total flow
hold on
grid minor
area(y,q_us,'FaceColor',[0.07 0.62 1]); % usable flow
plot([0 0; 4000 4000], [mu*1.25 0.75*mu; mu*1.25 0.75*mu],'k--')
plot([h_w h_w].*10,[0 2000],'Color','r','LineWidth',1.5)
bar(y,v_h*1e2,'BarWidth',0.2,'FaceColor',[0.72 0.27 1])
%% Plotting
figure
b = bar3(v_cutoff);
% b = bar3(v_usable);
% next lines come from matlab doc, are just to color bars according to
% value
for k = 1:length(b)
zdata = b(k).ZData;
b(k).CData = zdata;
b(k).FaceColor = 'flat';
end

title('Valore assoluto di velocità')
newTicksX = (xticks-1)*1e2 + startX;
xticklabels(newTicksX)
xlabel('X [mm]')
newTicksY = (yticks-1)*1e2 + startY;
yticklabels(newTicksY)
ylabel('Y [mm]')
zlabel('abs(v) [m s^{-1}]')