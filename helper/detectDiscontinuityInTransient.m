function [discontsAll] = detectDiscontinuityInTransient(transients, temporalBinCenters, discontDetectionPara, ...
                                                        whetherVisualize, visualizeRange)

% this function detects pathlength discontinuities in each transient
%
% Input:   transients:            n*m matrix, n: #transient, m: #temporal bins
%          temporalBinCenters:    pathlength bin centers (cm), 1*m vector for all n transients or n*m matrix for each transient indivisually
%          discontDetectionPara:  a struct that stores parameters for detecting discontinuities
%          whetherVisualize:      a boolean determines whether visualize discontinuty detection for each transient
% Output:  discontsAll:           n*k matrix, storing discontinuities in transients, n: #transient, k: #discontinuities per transient


expCoeff              = discontDetectionPara.expCoeff;
sigmaBlur             = discontDetectionPara.sigmaBlur;
numOfDiscont          = discontDetectionPara.numOfDiscont;
convolveTwoSides      = discontDetectionPara.convolveTwoSides;
whetherSortDisconts   = discontDetectionPara.whetherSortDisconts;


numOfMeasurements = size(transients, 1);
numOfBinCenters   = size(temporalBinCenters, 1);
if numOfBinCenters == 1
    X = temporalBinCenters;
else
    assert(numOfBinCenters == numOfMeasurements);
end

discontsAll = nan(numOfMeasurements, numOfDiscont);

if whetherVisualize
    figure;
end

% parfor
for i = 1 : numOfMeasurements
    fprintf(' detecting discontinuities: %d (%d) \n', i, numOfMeasurements);
    
    if numOfBinCenters > 1
        X = temporalBinCenters(i, :);
    end
    Y = transients(i, :);
    Y = Y / max(Y);
    
    % ----- convolve transients with DoG filters, and keep the maximum filter response -----
    dgY = -Inf(size(Y));
    for expCoeffOne = expCoeff
        for sigmaBlurOne = sigmaBlur
            filter = generateFilter(expCoeffOne, sigmaBlurOne);
            if convolveTwoSides
                dgYOne = max(conv(Y, filter, 'same'), conv(Y, filter(end:-1:1), 'same'));
            else
                dgYOne = conv(Y, filter, 'same');
            end
            dgY = max(dgY, dgYOne);
        end
    end
    dgY = dgY / max(dgY);
    
    % ----- discontinuties correspond to larger filter responses -----
    [~, locsPeak, ~, p] = findpeaks(dgY, X, 'MinPeakProminence', 0);
    [~, indsP] = sort(p, 'descend');
    locsPeak = locsPeak(indsP);
    
    disconts = nan(1, numOfDiscont);
    if numel(locsPeak) >= numOfDiscont
        disconts = locsPeak(1 : numOfDiscont);
    else
        disconts(1 : numel(locsPeak)) = locsPeak;
    end
    
    if whetherSortDisconts
        disconts = sort(disconts, 'ascend');
    end
    
    % ----- store discont -----
    discontsAll(i, :) = disconts;
    
    
    % ----- visualization -----
    if whetherVisualize
        plot(X(visualizeRange), Y(visualizeRange), 'k-', 'LineWidth', 1);
        hold on;
        plot(X(visualizeRange), dgY(visualizeRange)*0.8, 'm-', 'LineWidth', 2);
        colors = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
        for d = 1 : length(disconts)
            plot(disconts(d), 0, 'Marker', 'o', 'MarkerSize', 8, ...
                 'MarkerEdgeColor', colors(d, :), 'MarkerFaceColor', colors(d, :));
        end
        title(i);
        grid on
        grid minor
        hold off
        
        drawnow;
        pause;
    end
    
end


end