function plotAngles(inStr,sideCoef)
angles = inStr.alpha;         % Extract angles
y_coords = inStr.z'./100;       % Extract Y-coordinates

% Compute X and Y components of the unit vectors
% angles_rad = deg2rad(angles); % Convert angles to radians
u = cos(angles);          % X-components of unit vectors
v = sin(angles);          % Y-components of unit vectors

% Define the starting points of the vectors
x_start = zeros(size(y_coords)); % Start all vectors at X = 0

% Plot the vectors
% figure;
quiver(x_start, y_coords, sideCoef.*u, v,0, 'r', 'LineWidth', 1.5); % Scale = 0 to keep unit length
ylabel('Y');
grid on;
% axis equal; % Equal scaling for X and Y axes
    if sideCoef == -1
        xLimits = [-1 0];
        ylabel('Height [mm]')
        set(gca,'YAxisLocation','left')
    else
        xLimits = [0 1];
        % set(gca,'YAxisLocation','right')
    end
    set(gca,'XLim',xLimits);   % Restrict x field
end