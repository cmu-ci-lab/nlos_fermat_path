
% ===== compute x and y derivatives =====
[xDAll, yDAll, kAll, fitErrorAll] = computeXYDerivativesLocalFitting(X, Y, Z, pathSurfaceDerivativePara);

% thresholding
xDAll(fitErrorAll > pathSurfaceDerivativePara.fitErrorThreshold) = NaN;
yDAll(fitErrorAll > pathSurfaceDerivativePara.fitErrorThreshold) = NaN;
xDAll(kAll < pathSurfaceDerivativePara.curvatureRatioThreshold) = NaN;
yDAll(kAll < pathSurfaceDerivativePara.curvatureRatioThreshold) = NaN;

fprintf(' local fitting done. \n');


%% ===== reconstruction =====
boundaryExcluded = (pathSurfaceDerivativePara.planeFittingRange + 1) / 2;

for j = 1 : size(Z, 2)
    % ray direction, according to eikonal equation (|gradient| = 1)
    xD = xDAll(:, j);
    yD = yDAll(:, j);
    zD = sqrt(1 - xD.^2 - yD.^2);
    
    % LOS wall hard-coded to be z = 0
    directionFromDet = [-xD -yD zD]';
    indsComplex = (imag(directionFromDet(3, :)) ~= 0);
    directionFromDet(:, indsComplex) = NaN;

    det = detLocs';
    if whetherConfocal
        src = det;
    else
        src = repmat(srcLoc, [size(detLocs, 1) 1])';
    end
    pathlength = pathDiscont(:, j)';
    
    % ellipsoid (sphere) - ray intersection
    [points, pointsNormal] = ellipsoidRayIntersection(src, det, pathlength, directionFromDet);
    
    % exclude boundary points
    detGridSize = pathSurfaceDerivativePara.detGridSize;
    [xx, yy] = meshgrid(1+boundaryExcluded:detGridSize(2)-boundaryExcluded, 1+boundaryExcluded:detGridSize(1)-boundaryExcluded);
    indsCenter = sub2ind(detGridSize, yy, xx);
    ptc = points(:, indsCenter(:));
    ptcNormal = pointsNormal(:, indsCenter(:));
    
    % exclude complex values
    indsComplex = (imag(ptc(3, :)) ~= 0);
    ptc = ptc(:, ~indsComplex)';
    ptcNormal = ptcNormal(:, ~indsComplex)';
    
    % save reconstructed point clouds
    ptCloud = pointCloud(ptc, 'Normal', ptcNormal);
    filenameThis = fullfile(folderReconstruction, sprintf('recon_%s_%d%s', filename, j, '.ply'));
    pcwrite(ptCloud, filenameThis);
end

fprintf(' saving point clouds done. \n');


%% ===== x, y derivatives visualization =====
if whetherVisualizexDyDzD
    figure;
    numRows = size(Z, 2);
    for j = 1 : size(Z, 2)
        xD = xDAll(:, j);
        yD = yDAll(:, j);
        zD = sqrt(1 - xD.^2 - yD.^2);
        zD(imag(zD)~=0) = NaN;
        
        subplot(numRows, 3, j*3-2);
        Vq = griddata(X, Y, xD, Xq, Yq);
        surf(Xq, Yq, Vq, 'FaceColor', 'b', 'FaceAlpha', 0.3);

        subplot(numRows, 3, j*3-1);
        Vq = griddata(X, Y, yD, Xq, Yq);
        surf(Xq, Yq, Vq, 'FaceColor', 'b', 'FaceAlpha', 0.3);

        subplot(numRows, 3, j*3);
        Vq = griddata(X, Y, zD, Xq, Yq);
        surf(Xq, Yq, Vq, 'FaceColor', 'b', 'FaceAlpha', 0.3);
        drawnow;
    end
end
