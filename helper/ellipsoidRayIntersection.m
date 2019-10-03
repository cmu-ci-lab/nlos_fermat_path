function [point, pointNormal] = ellipsoidRayIntersection(src, det, pathlength, dirFromDet)

% this function implements ellipsoid (sphere if confocal) - ray intersection for recovering NLOS points and their normals
%
% Input:    src:              3*n  virtual source locations on LOS wall (same as det if confocal)
%           det:              3*n  virtual detector locations on LOS wall 
%           pathlength:       1*n  
%           dirFromDet:       3*n  ray direction
% Output:   point:            3*n  reconstructed points
%           pointNormal:      3*n  normals of reconstructed points

dirFromDet = dirFromDet ./ repmat(sqrt(sum(dirFromDet.^2, 1)), [3 1]);
srcToDet = det - src;
t = (pathlength.^2 - sum(srcToDet.^2, 1)) ./ (2*(sum(srcToDet.*dirFromDet, 1) + pathlength));
point = det + repmat(t, [3 1]) .* dirFromDet;

center = (det + src) / 2;
pointNormal = center - point;
pointNormal = pointNormal ./ repmat(sqrt(sum(pointNormal.^2, 1)), [3 1]);

% assert(isempty(find(t < 0, 1)));
% assert(isempty(find(abs(sqrt(sum((point-src).^2, 1)) + t - pathlength) > 1e-6, 1)));

end