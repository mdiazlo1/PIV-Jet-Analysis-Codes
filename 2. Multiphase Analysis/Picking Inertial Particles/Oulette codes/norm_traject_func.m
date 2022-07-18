function [ x_norm ] = norm_traject_func( x,mean_x )
%NORM_TRAJECT_FUNC removes a mean velocity from each trajectory

x_norm = x - mean_x * (0:(numel(x)-1));
end

