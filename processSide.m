function [sideResults] = processSide(rawData,side)
if nargin > 1
    % t.d: check that side is a char/categorical
    impN = rawData(rawData.side == side,:);   % only taking the results from one side. No idea why I called it "impN" in the first place.
else
    impN = rawData;
    side = 'Pippo';
end
% For L-R configs: which field is larger? adapt to that one
startX = min(impN.px);
startZ = min(impN.py);  % The system calls it y, but globally would be a z (vertical). Correcting this for clarity
nX = (max(impN.px) - startX)/1e2 + 1; % number of x steps
nZ = (max(impN.py) - startZ)/1e2 + 1; % number of z steps
velComponents = zeros(nZ,nX,3);  % 3D array containing the field of velocity components

z = (startZ/100 : 2+nZ).*100;  % heights vector
sideResults.z = z;   % Save it

for j = 1:height(impN)
    idX = (impN.px(j) - startX)/1e2 + 1;
    idZ = (impN.py(j) - startZ)/1e2 + 1;
    velComponents(idZ,idX,1:3) = table2array(impN(j,4:6));
end

%% Prepare the dataset

switch evalin('caller','procMethod')
    case {'abs'}
       rawVelocities = vecnorm(velComponents,2,3);    % 2-Norm of velocity vector
    case {'x'}
        rawVelocities = velComponents(:,:,1);   % Vx component
    case {'xz'}
        rawVelocities = sqrt( velComponents(:,:,1).^2 + velComponents(:,:,3).^2 );   % Vxz component
    otherwise
        disp('Unknown method.')
        return
end

xzAnglesField = atan(velComponents(:,:,3)./velComponents(:,:,1)); % angles of the airspeeds from horizontal
%% This part is probably heavily optimisable
v_cutoff = zeros(size(rawVelocities)); % initialise matrix to apply filters (cut-off, maximum speed, ...)
i_cutoff = find(rawVelocities>=1.5);    % fin index of all velocities > 1.5 m/s (cut-off)
v_cutoff(i_cutoff) = rawVelocities(i_cutoff);  % copy elements indexed into new matrix

v_usable = zeros(size(rawVelocities)); % as above, specifically for v_usable
i_usable = find( v_cutoff >= evalin('caller','vmin_usable') );
[r_u, c_u] = ind2sub(size(rawVelocities),i_usable);

% this cycle checks that there are more than 2 measurements at each height
% with speed more than usable
% % NOTE: THE INDEX IS (PREDICTABLY) ITERATIVELY CHANGING: You may see a
% streak of rows "#1" removed. Would be nice to fix that but not
% foundmental
for j = 1:max(r_u)
    cd = r_u == j;
    if sum(cd) == 1
        I = find(cd);
        % r_usable(I) = [];
        % c_usable(I) = [];
        r_u(I) = [];
        c_u(I) = [];
        fprintf('Removed row #%i from side %s\n',I,side)
    end
end

i_usable = sub2ind(size(rawVelocities),r_u,c_u);
v_usable(i_usable) = v_cutoff(i_usable);  % copy elements indexed into new matrix

%% Volumes
% % for each height h, q(h) = sum_i(A*v(h,i)), where A = 1e-2 m^2, area of
% sampling point, and has to be corrected for 3.6e+3 s/h, since speed is in
% m/s and q referred to h.  % wtf did I write? must have fucked up with a
% search/replace...
q_tot = sum(v_cutoff,2)*36; % total (after bkg noise cutoff)
q_us = sum(v_usable,2)*36;  % usable

%% Angles
a_usable = zeros(size(rawVelocities));
a_usable(i_usable) = xzAnglesField(i_usable);

a_h = zeros(nZ,1);
for h = 1:nZ  % weighted mean
    if q_us(h) == 0
        a_h(h) = 0;
    else
    a_h(h) = a_usable(h,:)*v_usable(h,:)'/sum( v_usable(h,:) );
    end
end

%% GENERATE OUTPUT STRUCT
% % t.d. order these, give them significant names
sideResults.Q = [q_tot q_us];
sideResults.QLegenda = ['total, usable'];   % Just carrying this over to remember who is who
sideResults.alpha = a_h;
% % maximum recorded speed f(h)
sideResults.vMax = max(v_cutoff,[],2);  % no need to carry over the usable: they're just the ones > vMin
end