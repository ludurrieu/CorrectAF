# CorrectAF
ImageJ macro for the correction of autofluorescence by linear unmixing in images with two fluorescent channels and the creation of radiometric images.

This macro is meant to correct background or autofluorescence contributions to fluorescent images for ratiometric analysis, such as those from FRET or fluorescent timer experiments. Briefly, for the autofluorescence correction, it substracts from the fluorescent images a weighted auto-fluorescence image that needs to be acquired for this purpose. 
It accepts two different inputs: lambda scans from confocal microscopes, o three-channel stacks. Lambda scans are converted into three channel images by difining the 2 fluorophores and the autofluorescence wavelengths windows.
The weighting constant can be defined in two ways: if the experimental design permits, it can be estimated using this macro by selecting a region of the image that has a similar composition to teh region of interest, but no fluorescent proteins. Otherwise, a weighting constant value can be manually introduced (this value has to be pre-estimated in independent experiments).

The intensity weighted ratiometric image is created by dividing the first fluorescent channel image by the second one to produce a gray-scale ratiometric image. Then, a LUT of choice is applied and the image is converted to RGB. Each RGB channel is multiplied independently by the second channel image to bring the intensity information back. Finally, the three channels are converted to tiff to get the intensity-weighted ratio- metric image.
