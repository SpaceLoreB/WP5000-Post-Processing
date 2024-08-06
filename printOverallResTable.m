function out = printOverallResTable(outStr,cfgName)
% The input structure "config" contains:
% - parameters (h_w, v_min)

if nargin == 2
    fname = [cfgName '_OverallsTable.txt'];
elseif nargin == 1
    fname = [inputname(1) '_OverallsTable.txt'];
else
    disp('Bro WTF');
    return
end

% % Creating a txt file, putting some basic headers
fileID = fopen(fname,'w');
fprintf(fileID,'\\toprule\n');
fprintf(fileID, ' & \t Sinistra \t&\t\\%% $Q_{tot}$\t&\t Destra \t&\t\\%% $Q_{tot}$\t&\t Soglia \t&\t Note \\\\ \n');
fprintf(fileID,'\\midrule\n');

% pre-formatting lines
formatSpecPerc = '%s \t&\t \\multicolumn{2}{c|}{%.1f\\%%} \t&\t \\multicolumn{2}{c|}{%.1f\\%%} \t&\t \t&\t \\\\ \n'; 
formatSpecNormal = '%s \t&\t %.0f \t&\t %.1f\\%% \t&\t %.0f \t&\t %.1f\\%% \t&\t \t&\t \\\\ \n';

% Print Qtot
fprintf(fileID,'%s \t&\t \\multicolumn{2}{c|}{%.0f} \t&\t \\multicolumn{2}{c|}{%.0f} \t&\t \t&\t \\\\ \n','Portata totale $Q_{tot}$',outStr.results.Qtot(1),outStr.results.Qtot(2));
fprintf(fileID,'%s \t&\t \\multicolumn{4}{c|}{%.0f} \t&\t \t&\t \\\\ \n','Somma dei lati', sum(outStr.results.Qtot) );
fprintf(fileID,'%s \t&\t \\multicolumn{4}{c|}{%.1f \\%%} \t&\t \t&\t \\\\ \n','Divergenza S/D', abs((outStr.results.Qtot(1) - outStr.results.Qtot(2)) / outStr.results.Qtot(1))*100 );

% Q_Usable and related stats (CV, outliers)
fprintf(fileID,'\\midrule\n');
fprintf(fileID,formatSpecNormal, sprintf('Portata utile fino a %.1f m',outStr.params(1)/100), outStr.results.Q_Usable2hw_tot(1),outStr.results.Q_Usable2hw_perc(1), outStr.results.Q_Usable2hw_tot(2),outStr.results.Q_Usable2hw_perc(2) );
fprintf(fileID,'%s \t&\t \\multicolumn{4}{c|}{%.0f (%.1f  \\%%)} \t&\t \t&\t \\\\ \n','Portata utile totale (\% $Q_{tot}$)', sum(outStr.results.Q_Usable2hw_tot), sum(outStr.results.Q_Usable2hw_tot)/sum(outStr.results.Qtot)*100 );
fprintf(fileID,'%s \t&\t \\multicolumn{4}{c|}{%.1f \\%%} \t&\t \t&\t \\\\ \n','Divergenza S/D', 100*abs((outStr.results.Q_Usable2hw_tot(1) - outStr.results.Q_Usable2hw_tot(2)) / outStr.results.Q_Usable2hw_tot(1)) );

fprintf(fileID,formatSpecPerc,'Coefficiente di variazione della portata utile',outStr.results.Q_Us_muStdCV(3,1),outStr.results.Q_Us_muStdCV(3,2));
fprintf(fileID,formatSpecPerc,'Portata utile oltre il 25\% della media',outStr.results.Q_outliers(1),outStr.results.Q_outliers(2));

% Potentially usable (slightly above, top)
fprintf(fileID,'\\midrule\n');
fprintf(fileID,formatSpecNormal, sprintf('Portata pot. utile fra %.1f m e %.1f m',outStr.params(1)/100,outStr.params(1)/100+0.5), outStr.results.Q_PotUsableOverWH_tot(1),outStr.results.Q_PotUsableOverWH_perc(1), outStr.results.Q_PotUsableOverWH_tot(2),outStr.results.Q_PotUsableOverWH_perc(2));
fprintf(fileID,formatSpecNormal, sprintf('Portata pot. utile oltre %.1f m',outStr.params(1)/100+0.5), outStr.results.Q_PotUsable2hihg_tot(1),outStr.results.Q_PotUsable2hihg_perc(1), outStr.results.Q_PotUsable2hihg_tot(2),outStr.results.Q_PotUsable2hihg_perc(2));

% Non usable
fprintf(fileID,'\\midrule\n');

fprintf(fileID,formatSpecNormal, sprintf('Portata inefficace fino a %.1f m',outStr.params(1)/100) ,outStr.results.Q_NonUsable2hw_tot(1),outStr.results.Q_NonUsable2hw_perc(1), outStr.results.Q_NonUsable2hw_tot(2),outStr.results.Q_NonUsable2hw_perc(2) );
fprintf(fileID,formatSpecNormal, sprintf('Portata inefficace fra %.1f m e %.1f m',outStr.params(1)/100,outStr.params(1)/100+.5), outStr.results.Q_NonUsableOverWH_tot(1),outStr.results.Q_NonUsableOverWH_perc(1), outStr.results.Q_NonUsableOverWH_tot(2),outStr.results.Q_NonUsableOverWH_perc(2));
fprintf(fileID,formatSpecNormal, sprintf('Portata inefficace oltre %.1f m',outStr.params(1)/100+.5)', outStr.results.Q_NonUsable2hihg_tot(1),outStr.results.Q_NonUsable2hihg_perc(1), outStr.results.Q_NonUsable2hihg_tot(2),outStr.results.Q_NonUsable2hihg_perc(2));

fprintf(fileID,'\\bottomrule\n');

% % We're done
out = fclose(fileID);
end