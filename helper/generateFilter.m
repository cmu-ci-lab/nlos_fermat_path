function [Pdg] = generateFilter(expCoeff, sigmaBlur)

% this function generates a Difference of Gaussian filter with exponential falloff
%
% Input:    expCoeff:       exponential falloff
%           sigmaBlur:      standard deviation of the guassian kernel
% Output:   Pdg:            DoG filter with an exponential falloff

t = [-5 : 0.1 : 5]';
ind = find(t == 0);
delta = zeros(size(t));
delta(ind) = 1;
deltas = zeros(size(t));
deltas(ind+1) = 1;

Pd = delta + deltas * (-exp(-expCoeff * 0.001)); 
G = exp(-t.^2 / sigmaBlur^2);
Pdg = conv(Pd, G, 'same');

end