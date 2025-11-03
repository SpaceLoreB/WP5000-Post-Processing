function [v_valid, v_absolute_valid, I,J, v_absolute] = validate_Velocities(v_raw, cutoff)
% get absolute velocities
    v_absolute = vecnorm(v_raw,2,3);
% initialise matrix to apply cut-off filter
    v_valid = zeros(size(v_raw));
% indexes at which v_abs > cutoff
    [I,J] = find(v_absolute >= cutoff);
    % Matlab per cortesia cagati addosso
    for L = 1:length(I)
        v_valid(I(L),J(L),:) = v_raw(I(L),J(L),:);
    end
% re-do v_absolute
    v_absolute_valid = vecnorm(v_valid,2,3);
end