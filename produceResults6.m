function resStruct = produceResults6(outStr)
% TO-DO: get angle at WH (make sure it agrees with table)

% Index of z corresp. to WH (saving it)
% WHindex = find(outStr.S1.z >= outStr.params(1)*10,1,'first');
WHindex = length(outStr.S1.z);
resStruct.WHindex = WHindex;

Qtot = zeros(1,6);
Q_Usable2wh = zeros(WHindex,6);
Q_NonUsable2wh = Q_Usable2wh;
Q_Us_muStd_sides = zeros(2,6);
% The rest is fucking optional so get rekt

for i = 1:6
    sideName = ['S' num2str(i)];
    % Total flow rate/side
    Qtot(i) = sum(outStr.(sideName).Q(:,1));
    Q_Usable2wh(:,i) = outStr.(sideName).Q(1:WHindex,2);
    Q_NonUsable2wh(:,i) = outStr.(sideName).Q(1:WHindex,1);
    % means
    Q_Us_muStd_sides(:,i) = [ mean( Q_Usable2wh( Q_Usable2wh(:,i) ~= 0 , 1) ); std( Q_Usable2wh( Q_Usable2wh(:,i) ~= 0 , 1) ) ];
end

% % Finalise porcessing and assign to results
resStruct.Qtot = Qtot;
% Q usable up to WH
Q_Usable2hw_tot = sum(Q_Usable2wh,1);
% Need this for plotting but otherwise wouldn't care
resStruct.xmax = max(Q_NonUsable2wh,[],'all');

resStruct.Q_Usable2hw_tot = Q_Usable2hw_tot;
resStruct.Q_Usable2hw_perc = Q_Usable2hw_tot./Qtot.*100;
% Q NON-usable up to WH
Q_NonUsable2hw_tot = sum(Q_NonUsable2wh,1)-Q_Usable2hw_tot;
resStruct.Q_NonUsable2hw_tot = Q_NonUsable2hw_tot;
resStruct.Q_NonUsable2hw_perc = Q_NonUsable2hw_tot./Qtot.*100;
% Mean, std, cv of usable: the original system gets the mean of the non-zero elements
% Computing CV directly while saving
resStruct.Q_Us_muStdCV = [Q_Us_muStd_sides; Q_Us_muStd_sides(2,:)./Q_Us_muStd_sides(1,:).*100];
resStruct.Q_Us_muStd_overall = [mean(Q_Us_muStd_sides(1,:)) std(Q_Us_muStd_sides(1,:))];

% % FOLLOWING PART DOES NOT WORK IF INVESTIGATED AREA IS SMALL (i.e. arrays are not tall enough to check what's at 6 elements above working height)

% % potentially usable/nonusable up to WH + 0.5 m
% Q_PotUsableOverWH = [outStr.(sideName).Q(WHindex+1:WHindex+5,2) outStr.R.Q(WHindex+1:WHindex+5,2)];
% Q_PotUsableOverWH_tot = sum(Q_PotUsableOverWH,1);
% resStruct.Q_PotUsableOverWH_perc = Q_PotUsableOverWH_tot./Qtot.*100;
% resStruct.Q_PotUsableOverWH_tot = Q_PotUsableOverWH_tot;
% 
% Q_NonUsableOverWH = [outStr.(sideName).Q(WHindex+1:WHindex+5,1) outStr.R.Q(WHindex+1:WHindex+5,1)];
% Q_NonUsableOverWH_tot = sum(Q_NonUsableOverWH,1);
% resStruct.Q_NonUsableOverWH_perc = Q_NonUsableOverWH_tot./Qtot.*100;
% resStruct.Q_NonUsableOverWH_tot = Q_NonUsableOverWH_tot;
% 
% % potentially usable/nonusable above WH + 0.5 m
% Q_PotUsable2hihg = [outStr.(sideName).Q(WHindex+6:end,2) outStr.R.Q(WHindex+6:end,2)];
% Q_PotUsable2hihg_tot = sum(Q_PotUsable2hihg,1);
% resStruct.Q_PotUsable2hihg_perc = Q_PotUsable2hihg_tot./Qtot.*100;
% resStruct.Q_PotUsable2hihg_tot = Q_PotUsable2hihg_tot;
% 
% Q_NonUsable2hihg = [outStr.(sideName).Q(WHindex+6:end,1) outStr.R.Q(WHindex+6:end,1)];
% Q_NonUsable2hihg_tot = sum(Q_NonUsable2hihg,1);
% resStruct.Q_NonUsable2hihg_perc = (Q_NonUsable2hihg_tot)./Qtot.*100;
% resStruct.Q_NonUsable2hihg_tot = Q_NonUsable2hihg_tot;

% % Outliers: the original system COUNTS the amount of data points outside of p/m 25%. That sucks, so I'll count the total flow rate
% for side = 1:2
% Idx = [find(  Q_Usable2wh(:,side) > 1.25*Q_Us_muStd(1,side) ); 
%     find( Q_Usable2wh(:,side) < 0.75*Q_Us_muStd(1,side) )];
% Qbuffer(side) = sum( Q_Usable2wh(Idx,side) );
% end
% resStruct.Q_outliers = Qbuffer./Q_Usable2hw_tot.*100;

disp('Processing done');
end