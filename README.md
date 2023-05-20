# CorrectAF
ImageJ macro (written in ImageJ macro lenguage) for the correction of autofluorescence by linear unmixing in images with two fluorescent channels, and the creation of radiometric images.

This macro is meant to correct background or autofluorescence contributions of fluorescence microscopy images for ratiometric analysis, such as the output from FRET or fluorescent timer experiments. 

![Screen Shot 2023-05-16 at 7 57 30 PM](https://github.com/ludurrieu/CorrectAF/assets/79978782/9c26ef9e-4a94-4a0c-ae4e-710aa8179f22)


Briefly, for the autofluorescence correction, it substracts from the fluorescent images a weighted auto-fluorescence image that needs to be acquired for this purpose. 
It accepts two different inputs: lambda scans from confocal microscopes (by selecting "Create channel images from lambda scan"), o three-channel stacks (by leaving it un-checked). Lambda scans are converted into three channel images by difining the 2 fluorophores and the autofluorescence wavelengths windows. Images can be in the formats tiff, lsm or hdf5.
The weighting constant can be defined in two ways: if the experimental design permits, it can be estimated using by selecting a region of the image that has a similar composition to teh region of interest, but no fluorescent proteins (by selecting "Auto-calibrate weight of the AF image"). Otherwise, a weighting constant value can be manually introduced (this value has to be pre-estimated in independent experiments)(in "Weight of the AF image").

The intensity weighted ratiometric image is created by dividing the first fluorescent channel image by the second one to produce a gray-scale ratiometric image. The "Max range of the ratio" value is used here to set the constrast values. Might be worth it to play around with a few values. Then, a LUT of choice is applied and the image is converted to RGB. Each RGB channel is multiplied independently by the second channel image to bring the intensity information back. Finally, the three channels are converted to tiff to get the intensity-weighted ratio- metric image.

## Expected output:

Input: 3 channel image from FRET experiment (example_FRET.lsm)

![Montage_input](https://github.com/ludurrieu/CorrectAF/assets/79978782/293bad47-a1a7-49d5-8feb-0dbf75e639e6)

Left: CFP, Middle: YFP, Right: AF (autofluorescence decicated channel)

Output: Auto-fluorescence corrected images + intensity-weigthed ratiometric image

![Montage_output](https://github.com/ludurrieu/CorrectAF/assets/79978782/b3259917-98b7-471f-a719-f2a74f62d66a)

Left: Ratio with very tiny scalebar (of course, it can be adjusted), Middle: CFP, Right: YFP (autofluorescence decicated channel)

Note: the macro saves all output images in a folder, the montage was made afterwards

## More information

For a detailed description of the steps and use of this macro, see
Metabolic FRET sensors in intact organs: Applying spectral unmixing to acquire reliable signals. L Gándara, L Durrieu and P Wappner, 2023.

Some version of this macro was used in these papers: 
* Bicoid gradient formation mechanism and dynamics revealed by protein lifetime analysis. Durrieu, Lucía, Kirrmaier, Daniel, Schneidt, Tatjana, Kats, Ilia, Raghavan, Sarada, Knop, Michael, Saunders, Timothy E, Hufnagel, Lars
(for fluorescent timers and Light-Sheet Imaging)
* A genetic toolkit for the analysis of metabolic changes in Drosophila provides new insights into metabolic responses to stress and malignant transformation. L Gándara, L Durrieu, C. Beherensen and P Wappner, 2019. 
(for Intramolecular FRET quth spectral confocal imaging)

