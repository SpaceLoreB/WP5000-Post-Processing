function out = makeResTable(config,cfgName)
% The input structure "config" contains:
% - parameters (h_w, v_min)
% - processing method
% - two (or more, WIP) substructures, containing:
%   -- y
%   -- Q
%   -- Alpha
%   -- vMax

% Would be healthy to run a background check:
% [outdated once same y is used for both sides]
if any(config.L.y ~= config.L.y)
    disp('y vectors not matching!')
    return
else
    disp('y vectors matching, proceeding')
end

% If you specified a name, use it, otherwise make it
if nargin == 2
    fname = [cfgName '_resTable.txt'];
elseif nargin == 1
    fname = [inputname(1) '_resTable.txt'];
else
    disp('Bro WTF');
    return
end

% % Creating a txt file, putting some basic headers
fileID = fopen(fname,'w');
fprintf(fileID,'\\toprule\n');
fprintf(fileID, 'h [cm] \t & \t Sx \t & \t Dx \t & \t Mean \t & \t Dev.[\\%%] \\\\ \n');
fprintf(fileID,'\\midrule\n');

% % Printing the main part of the (flow rates) table
Ly = length(config.L.y);
% Knowing where to place a midrule to separate working heigth
I_row = find(config.L.y == config.params(1)*10);
% Pre-formatting the table (needed also for angles)
formatSpec = '%d \t&\t %.1f \t&\t %.1f \t&\t %.1f \t&\t %.1f \\\\ \n';
for k = 1:Ly
    i = Ly+1-k;
    if i == I_row
        fprintf(fileID,'\\midrule\n');
    end
    % temporary variable to avoid becoming stupid(er) with km-long lines
    res = [config.L.Q(i,2) config.R.Q(i,2)];    % usable flow rates
    res = [config.L.y(i)/10, res, mean(res) abs((res(1)-res(2))/res(1))*100];
    fprintf(fileID,formatSpec,res);
end
fprintf(fileID,'\\bottomrule\n');

% % Now the same for angles. Give it some space
fprintf(fileID,'\n\n\n');
% % Printing the main part of the (flow rates) table
for k = 1:Ly
    i = Ly+1-k;
    if i == I_row
        fprintf(fileID,'\\midrule\n');
    end
    % temporary variable to avoid becoming stupid(er) with km-long lines
    res = rad2deg([config.L.alpha(i) config.R.alpha(i)]);    % velocity-averaged angles
    res = [config.L.y(i)/10, res, mean(res) abs((res(1)-res(2))/res(1))*100];
    fprintf(fileID,formatSpec,res);
end
fprintf(fileID,'\\bottomrule\n');

% % We're done
out = fclose(fileID);
end