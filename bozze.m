% C3dH = importfile("C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing\UniBz_W 000024_C3dL.csv", [2, Inf]);

%%
impN = C3dH(C3dH.ma == 'NL',:);   % only taking the results from 'NL' test
varName = 'C3L4';

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
strNalpha = atan(strN(:,:,1)./strN(:,:,3)); % angles of the airspeeds from horizontal
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

% NOT WORKING SO I AM SKIPPING TEH WHOLE CALCULATION
% % this cycle checks that there are more than 2 measurements at each height
% % with speed more than 4 m/s
% for j = 1:max(r_u)
%     cd = r_u == j;
%     if sum(cd) == 1
%         I = find(cd);
%         r_usable(I) = [];
%         c_usable(I) = [];
%         fprintf('Removed row #%i\n',I)
%     end
% end
% clear cd j I

i_usable = sub2ind(size(strNvx),r_usable,c_usable);
v_usable(i_usable) = v_cutoff(i_usable);  % copy elements indexed into new matrix

%% Volumes
% % for each height h, q(h) = sum_i(A*v(h,i)), where A = 1e-2 m^2, area of
% sampling point, and has to be corrected for 3.6e+3 s/h, since speed is in
% s/h and q referred to h.
q_h = sum(v_cutoff,2)*36;
q_us = sum(v_usable,2)*36;

% q_us_tot/q_tot;
muStd = [mean(q_us(q_us ~= 0)) std(q_us(q_us ~= 0))];

%% Angles
a_usable = zeros(size(strNvx));
a_usable(i_usable) = strNalpha(i_usable);

a_h = zeros(nY,1);
% for h = 1:nY  % weighted mean
%     a_h(h) = a_usable(h,:)*v_usable(h,:)'/q_us(h);
% end
a_h = mean(a_usable,2);
% 
% rad2deg( a_h( find(y<=h_w*10,1,'last') ) )    % angle at working height

%% PUT THIS STUFF INTO A STRUCT
% % DONE
outStr = struct;
outStr.q_h = q_h;
outStr.q_us = q_us;
outStr.q_tot = sum(q_h);
outStr.q_us_tot = sum(q_us);
outStr.y = y;
outStr.muStd = muStd;
outStr.cv = muStd(2)/muStd(1);
assignin("base",varName,outStr)