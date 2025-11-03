function [qm_tot, qm_us, n_reps] = evalVariability(varargin)
% Use to merge several test repetitions. Accepts any number of structures from processSide().
% Use:
% [qm, n_reps] = reps(str1, ..., strN)
% qm contains average and st.dev. of air flow rates Q;
% n_reps is the number of input structures N
    n_reps = nargin;
    q_tot = zeros(height(varargin{1}.Q),n_reps); % TODO: check that all varargin are the same size
    q_us = q_tot;
    for k = 1:n_reps
        q_tot(:,k) = varargin{k}.Q(:,1);
        q_us(:,k) = varargin{k}.Q(:,2);
    end
    qm_tot = [mean(q_tot,2) std(q_tot,0,2)];
    qm_us =  [mean(q_us,2) std(q_us,0,2)];
end
