function [qm, n_reps] = reps(varargin)
    n_reps = nargin;
    q = zeros(height(varargin{1}.Q),n_reps);
    for k = 1:n_reps
        q(:,k) =  varargin{k}.Q(:,1);
    end
    qm = [mean(q,2) std(q,0,2)];
end