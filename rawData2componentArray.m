function sideStr = rawData2componentArray(rawData,side)
    if nargin > 1
        % t.d: check that side is a char/categorical
        rawData = rawData(rawData.side == side,:);   % only taking the results from one side. No idea why I called it "impN" in the first place.
    end
    % For L-R configs: which field is larger? adapt to that one
    startX = min(rawData.px);
    startZ = min(rawData.py);  % The system calls it y, but globally would be a z (vertical). Correcting this for clarity
    nX = (max(rawData.px) - startX)/1e2 + 1; % number of x steps
    nZ = (max(rawData.py) - startZ)/1e2 + 1; % number of z steps
    velComponents = zeros(nZ,nX,3);  % 3D array containing the field of velocity components
    
    sideStr.localZ = (startZ/100 : 2+nZ).*100;  % heights vector
    
    for j = 1:height(rawData)
        idX = (rawData.px(j) - startX)/1e2 + 1;
        idZ = (rawData.py(j) - startZ)/1e2 + 1;
        velComponents(idZ,idX,1:3) = table2array(rawData(j,4:6));
    end
    sideStr.velComponents = velComponents;
end