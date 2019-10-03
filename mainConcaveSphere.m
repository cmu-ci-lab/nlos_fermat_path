
clear;
clc;
close all;
addpath(genpath('./'));

% parameters
filename              = 'concaveSphere';
folderData            = './data';
folderReconstruction  = './reconstructions';
load(fullfile(folderData, filename));

whetherConfocal   = true;       % whether confocal setting (colocated virtual source and detecotr)


%% ===== detecting discontinuities in transients =====
% ----- parameters -----
discontDetectionPara.expCoeff             = [0, 1];          % model the exponential falloff of the SPAD signal
discontDetectionPara.sigmaBlur            = [1];       % Difference of Gaussian, standard deviation
discontDetectionPara.numOfDiscont         = 4;            % number of discontinuities per transient
discontDetectionPara.convolveTwoSides     = true;        % convolve transient with DoG filter in both sides (for detecting local minimum/maximum)
discontDetectionPara.whetherSortDisconts  = true;        % whether sort discontinuities

% ----- pathlength discontinuties visualization  -----
whetherVisualizePDSurface       = true;
whetherVisualizePDIndivisually  = false;
visualizaRange                  = 1:4000;

detectDiscontinuity;


%% ===== Fermat Flow (sphere-ray intersection) =====
% ----- parameters for computing x and y derivatives -----
pathSurfaceDerivativePara.detGridSize              = detGridSize;
pathSurfaceDerivativePara.planeFittingRange        = 5;           % local 5*5 patch for estimating x and y derivatives, odd number, at least 3
pathSurfaceDerivativePara.spatialSigma             = 8;           % bilateral filtering, spatial gaussian blur kernel size
pathSurfaceDerivativePara.diffSigma                = 10;          % bilateral filtering, range gaussian blur kernel size
pathSurfaceDerivativePara.fitErrorThreshold        = 6e-4;        % reconstruction threshold, larger the value, looser the constraint
pathSurfaceDerivativePara.curvatureRatioThreshold  = 6e-5;           % reconstruction threshold, smaller the value, looser the constraint

% ----- x, y derivatives visualization -----
whetherVisualizexDyDzD = true;

fermatFlowReconstruction;
