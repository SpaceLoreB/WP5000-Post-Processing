C3dH = importfile("C:\Users\LBecce\Desktop\WPpostpro\WP5000-Post-Processing\UniBz_W 000024_C2dH.csv", [2, Inf]);
% % variable name
varName = 'C3';
%% Working parameters
h_w = 350;    % work height [cm]
vmin_usable = 4;   % usable air speed [m/s]
% how to process: 'abs' = abs. val. of velocities,
% 'x' = x-component,
% 'xz' = xz-component (vertical)
procMethod = 'abs';

% % prepare output structure
% % carrying over parameters to enfore checks when comparing
outStr = struct('params',[h_w vmin_usable],'method',procMethod,'y',[]);

%% import table into single array
impN = C3dH(C3dH.side == 'R',:);   % only taking the results from one side

% % % <FROM HERE ON>: WRAP INTO FUNCTION, PASS PARAMS, OUTPUT SIDE DATA

% For L-R configs: which field is larger? adapt to that one
startX = min(impN.px);
startY = min(impN.py);
nX = (max(impN.px) - startX)/1e2 + 1; % number of x steps
nY = (max(impN.py) - startY)/1e2 + 1; % number of y steps
strN = zeros(nY,nX,3);  % structure to store the data

y = (startY/100 : 2+nY).*100;  % heights vector
outStr.y = y;   % Save it

for j = 1:height(impN)
    idX = (impN.px(j) - startX)/1e2 + 1;
    idY = (impN.py(j) - startY)/1e2 + 1;
    strN(idY,idX,1:3) = table2array(impN(j,4:6));
end

%% Prepare the dataset
switch procMethod
    case {'abs'}
       rawVelocities = vecnorm(strN,2,3);    % 2-Norm of velocity vector
    case {'x'}
        rawVelocities = strN(:,:,1);   % Vx component
    case {'xz'}
        rawVelocities = sqrt( strN(:,:,1).^2 + strN(:,:,3).^2 );   % Vxz component
    otherwise
        disp('Unknown method.')
end

strNalpha = atan(strN(:,:,1)./strN(:,:,3)); % angles of the airspeeds from horizontal
%%
v_cutoff = zeros(size(rawVelocities)); % initialise matrix to apply filters (cut-off, maximum speed, ...)
i_cutoff = find(rawVelocities>=1.5);    % fin index of all velocities > 1.5 m/s (cut-off)
v_cutoff(i_cutoff) = rawVelocities(i_cutoff);  % copy elements indexed into new matrix

v_usable = zeros(size(rawVelocities)); % as above, specifically for v_usable
i_usable = find(v_cutoff >= vmin_usable);

% croppig to h_w
% r_max = find( y == h_w );   % index of rows below h_w
[r_u, c_u] = ind2sub(size(rawVelocities),i_usable);
% i_heigth = find(r_u<=r_max);
% r_usable = r_u(i_heigth);
% c_usable = c_u(i_heigth);

% this cycle checks that there are more than 2 measurements at each height
% with speed more than usable
for j = 1:max(r_u)
    cd = r_u == j;
    if sum(cd) == 1
        I = find(cd);
        % r_usable(I) = [];
        % c_usable(I) = [];
        r_u(I) = [];
        c_u(I) = [];
        fprintf('Removed row #%i\n',I)
    end
end
clear cd j I

i_usable = sub2ind(size(rawVelocities),r_u,c_u);
v_usable(i_usable) = v_cutoff(i_usable);  % copy elements indexed into new matrix

%% Volumes
% % for each height h, q(h) = sum_i(A*v(h,i)), where A = 1e-2 m^2, area of
% sampling point, and has to be corrected for 3.6e+3 s/h, since speed is in
% s/h and q referred to h.
q_h = sum(v_cutoff,2)*36;
q_us = sum(v_usable,2)*36;

% % CAN BE CARRIED OUTSIDE OF FCN
muStd = [mean(q_us(q_us ~= 0)) std(q_us(q_us ~= 0))];

%% Angles
a_usable = zeros(size(rawVelocities));
a_usable(i_usable) = strNalpha(i_usable);

a_h = zeros(nY,1);
for h = 1:nY  % weighted mean
    if q_us(h) == 0
        a_h(h) = 0;
    else
    a_h(h) = a_usable(h,:)*v_usable(h,:)'/sum( v_usable(h,:) );
    end
end

%  % Find angle of usable speed at working height
a_WH = rad2deg( a_h( y == h_w ) );

%% PUT THIS STUFF INTO A STRUCT

% % % <UP TO HERE>: PRODUCE A SINGLE VARIABLE/CSV...

% % t.d. order these, give them significant names
outStr.Q = [q_h q_us];
outStr.q_tot = sum(q_h);
outStr.q_us_tot = sum(q_us);
outStr.alpha = a_h;
% outStr.muStd = muStd;
% outStr.cv = muStd(2)/muStd(1);
% assignin("base",varName,outStr)