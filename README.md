# nlos_fermat_path

This repository is an implementation of the method described in the following paper:

Shumian Xin, Sotiris Nousias, Kiriakos N. Kutulakos, Aswin C. Sankaranarayanan, Srinivasa G. Narasimhan, and Ioannis Gkioulekas. ["A Theory of Fermat Paths for Non-Line-of-Sight Shape Reconstruction"](http://imaging.cs.cmu.edu/fermat_paths/), CVPR 2019.

## Run code

Run ```main***``` scripts for various simulated non-line-of-sight (NLOS) shape reconstructions. Reconstructed point clouds are stored in ```reconstructions``` folder. **Note: line-of-sight (LOS) wall is hard-coded to be z = 0.**

```helper``` folder has a list of helper functions for detecting discontinuities in transients, conducting ellipsoid (sphere)-ray intersections, etc.

```data``` folder includes ground truth meshes, and ```.mat``` files storing the following inputs.

**Notes:** 

1) You may load ground truth meshes and reconstructed point clouds in a mesh displayer, such as Meshlab, to compare reconstructions against the ground truth. 

2) You might want to adjust parameters of the current transient discontinuities detector, or implement your own to best suit your data. The current one will not work well for transient measurements of complicated or multiple NLOS objects.

3) You may run any off-the-shelf surface reconstruction algorithm using point clouds, e.g. Poisson surface reconstruction, as a post-processing to the output.



## Inputs

| Parameter | Description |
|:---------|:---------|
| transients | an n * m matrix, n transient measurements with m temporal bins. Transients are calibrated by cutting out the direct components, such that t = 0 correpsonds to the path starting from a sensing point on the LOS wall. |
| temporalBinCenters | a 1 * m vector or an n * m matrix, path length bin centers (cm). 1 * m vector for all n transients or n * m matrix for each transient indivisually. For example, transient measurements with temporal resolution of 4 picoseconds will have path length resolution of 4ps * speed_of_light = 0.12cm, therefore [0.06(cm), 0.18, 0.30, ... ] as temporalBinCenters. |
| detLocs | an n * 3 matrix, n sensing point locations on the LOS wall. (**Tip:** LOS wall is hard-coded to be z = 0, thus the third column of this matrix should also be 0.) |
| detGridSize | [n1, n2], with n1 * n2 = n, grid size of sensing points on the LOS wall. |
| whetherConfocal | a boolean, whether or not a confocal setting.|
| srcLoc | an empty or a 1 * 3 vector, the laser position on the LOS wall. Empty in a confocal setting, will later be assigned the same values as detLocs. 1 * 3 vector for all sensing points in a non-confocal setting. |

