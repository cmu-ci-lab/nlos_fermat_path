function [xD, yD, k, fitError] = computeXYDerivativesLocalFitting(X, Y, Z, pathSurfaceDerivativePara)

% this functions computes x & y derivatives from pathlength surface using local fitting
%
% Input:   X, Y:                       n*1   x and y coordinates of pathlength surface
%          Z:                          n*k   pathlength surface, k: #discontinuities per transient
%          pathSurfaceDerivativePara:  a struct that stores parameters for detecting discontinuities
%          whetherVisualize:           a boolean determines whether visualize discontinuty detection for each transient
% Output:  xD, yD:                     n*k   x and y derivatives of each pathlength surface
%          k:                          n*k   curvature ratio
%          fitError:                   n*k   fitting error

xD        = NaN(size(Z));
yD        = NaN(size(Z));
k         = NaN(size(Z));
fitError  = NaN(size(Z));

detGridSize        = pathSurfaceDerivativePara.detGridSize;
planeFittingRange  = pathSurfaceDerivativePara.planeFittingRange;
spatialSigma       = pathSurfaceDerivativePara.spatialSigma;
diffSigma          = pathSurfaceDerivativePara.diffSigma;
temp               = (planeFittingRange - 1) / 2;

for j = 1 : size(Z, 2)
    
    for iy = 1 : detGridSize(1)
        IY = max(1, iy - temp) : min(detGridSize(1), iy + temp);

        for ix = 1 : detGridSize(2)
            IX = max(1, ix - temp) : min(detGridSize(2), ix + temp);
            fprintf(' local plane fitting %d (%d): %d (%d) \n', ...
                    j, size(Z, 2), (iy-1) * detGridSize(2) + ix, numel(X));

            indThis = sub2ind(detGridSize, iy, ix);
            x = X(indThis);
            y = Y(indThis);
            z = Z(indThis, j);
            
            [IXAll, IYAll] = meshgrid(IX, IY);
            indsLocal = sub2ind(detGridSize, IYAll(:), IXAll(:));
            XLocal = X(indsLocal);
            YLocal = Y(indsLocal);
            ZLocal = Z(indsLocal, j);
            
            indsNotNaN = ~isnan(ZLocal);
            if numel(find(indsNotNaN)) < 6
                continue;
            end
            
            % ----- local poly22 bilateral filtering -----
            % ----- spatial kernel -----
            gaussian2D = fspecial('gaussian', [planeFittingRange, planeFittingRange], spatialSigma);
            if (iy - temp) < 1
                gaussian2D = gaussian2D((2-(iy - temp)):end, :);
            end
            if (ix - temp) < 1
                gaussian2D = gaussian2D(:, (2-(ix - temp)):end);
            end
            if (iy + temp) > detGridSize(1)
                gaussian2D = gaussian2D(1:end-((iy + temp)-detGridSize(1)), :);
            end
            if (ix + temp) > detGridSize(2)
                gaussian2D = gaussian2D(:, 1:end-((ix + temp)-detGridSize(2)));
            end
            gaussianWeight = gaussian2D(:);
            
            % ----- range kernel -----
            xDiff = [-50 : 0.1 : 50];
            gaussian1D = normpdf(xDiff, 0, diffSigma);
            intensityDiff = z - ZLocal;
            intensityWeight = interp1(xDiff, gaussian1D, intensityDiff, 'pchip');

            weight = gaussianWeight .* intensityWeight;
            isNotNaN = find(~isnan(weight));
            if isNotNaN < 6
                continue;
            end
            
            % ----- linear system -----
            A = [XLocal.^2, YLocal.^2, XLocal.*YLocal, XLocal, YLocal, ones(size(XLocal))];
            solution = (repmat(weight(isNotNaN(:)), [1 6]) .* A((isNotNaN(:)), :)) \ (weight(isNotNaN(:)) .* ZLocal(isNotNaN(:)));
            a = solution(1); b = solution(2); c = solution(3); 
            d = solution(4); e = solution(5); f = solution(6);

            % ----- x and y derivatives -----
            xD(indThis, j) = 2*a*x + c*y + d;
            yD(indThis, j) = 2*b*y + c*x + e;
            
            % ----- curvature ratio -----
            fxx = 2*a; fyy = 2*b; fxy = c;
            if ~isnan(fxx + fxy + fyy)
                eg = eig([fxx fxy; fxy fyy]);
                eg = abs(eg);
                k(indThis, j) = min(eg) / max(eg);
            end
            
            % ----- fitting error -----
            fitError(indThis, j) = mean(abs(A((isNotNaN(:)), :) * transpose([a b c d e f]) - ZLocal(isNotNaN(:))));
            fitError(indThis, j) = fitError(indThis, j) / sqrt(mean(ZLocal(isNotNaN(:)).^2));
            
        end
        
    end
    
end


end