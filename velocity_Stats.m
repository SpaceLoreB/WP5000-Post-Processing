function statStruct = velocity_Stats(v_absolute)
% histogram of absolute velocities
[n, binEdges] = histcounts(v_absolute(v_absolute ~= 0),75);
% cdf of n
nCum = cumsum(n)./sum(n);
% centre of bins
binCentres = movsum(binEdges,2,"Endpoints","discard")./2;
%%
statStruct = struct('binEdges',binEdges,'binCentres',binCentres, ...
    'count',n,'cumCount',nCum);%, ... % NOT WORKING BC SOME DATASETS DON'T GET BELOW 10%
    % 'dVxx',[interpolateX(.10,binCentres,nCum) interpolateX(.50,binCentres,nCum) interpolateX(.9,binCentres,nCum)]);
end

function dVx = interpolateX(Y,ascissa,ordinata)
I = find(ordinata(ordinata < Y),1,'last');
dVx = ascissa(I) + ( Y - ordinata(I) )*( ascissa(I+1) - ascissa(I) )/( ordinata(I+1) - ordinata(I) );
end
