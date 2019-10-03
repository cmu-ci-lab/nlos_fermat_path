
% ===== detect discontinuities in transients =====
[pathDiscont] = detectDiscontinuityInTransient(transients, temporalBinCenters, discontDetectionPara, ....
                                               whetherVisualizePDIndivisually, visualizaRange);
fprintf(' detecting discontinuities done. \n');

X = detLocs(:, 1);
Y = detLocs(:, 2);

if whetherConfocal
    Z = pathDiscont / 2;
else
    Z = pathDiscont;
end


%% ===== discontinuities visualization =====
if whetherVisualizePDSurface
    xMin = min(X);    xMax = max(X);
    yMin = min(Y);    yMax = max(Y);
    detIntervalX = (xMax - xMin) / (detGridSize(1) - 1);
    detIntervalY = (yMax - yMin) / (detGridSize(2) - 1);
    xCoord = [xMin : detIntervalX : xMax];
    yCoord = [yMin : detIntervalY : yMax];
    [Xq, Yq] = meshgrid(xCoord, yCoord);
    
    figure;
    for i = 1 : discontDetectionPara.numOfDiscont
        pathThis = Z(:, i);
        F = scatteredInterpolant(X, Y, pathThis(:));
        Vq = F(Xq, Yq);
        if min(Vq(:)) == max(Vq(:)) || isnan(min(Vq(:)))
            continue;
        end
        
        subplot(discontDetectionPara.numOfDiscont, 2, i*2-1);
        imagesc([xMin xMax], [yMin yMax], Vq, [min(Vq(:)) max(Vq(:))]);
        title(sprintf('Surface %d', i));
        xlabel('x');
        ylabel('y');
        set(gca,'Ydir','Normal')
        colormap jet
        axis equal
        axis tight

        subplot(discontDetectionPara.numOfDiscont, 2, i*2);
        plot3(X, Y, pathThis(:), 'mo', 'MarkerSize', 3, 'MarkerFaceColor', 'm'); hold on;
        surf(Xq, Yq, Vq, 'FaceColor', 'b', 'FaceAlpha', 0.3);
        title(sprintf('Surface %d', i));
        xlim([xMin xMax]);
        ylim([yMin yMax]);
        xlabel('x');
        ylabel('y');
        axis equal
    end
end
