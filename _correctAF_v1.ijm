//works with either a spectral stack from a lambda scan or a stack of 3 channels (CFP, YFP and AF- IN THAT ORDER)
//allows to draw a ROI in an area without fluorescence to calibrate the linear unmixing or to introduce a previously calibrated value.
//makes a ratiomatric image
// works on tiff, lsm or hdf5
//works on single images or  stacks
//saves corrected images separetly in the same folder as tiffs
//the difference wth v2 is that it allows to choose a dofferent directory for saving images (this directory is expected to have a "green" and a "red" subfolder) and

//Lucia 11-08-2017

//get user input

dir = getDirectory("Choose the directory with image files to process ");

//--------------------------------


	// choose directory and get list of files

	fname= File.openDialog("Select an image to open");

		if (endsWith(fname,  ".h5")) {

   			run("Scriptable load HDF5...", "load="+ fname +" datasetnames=/Data nframes=1 nchannels=1");
			i_win= getTitle();		
   			}   else if (endsWith(fname,  ".tif")) {
				open(fname);
 				i_win= getTitle();
					}
				else if (endsWith(fname,  ".lsm")) {
				open(fname);
 				i_win= getTitle();
					}		

i_win_ne= File.nameWithoutExtension;

//--------------------
//start dialog

Dialog.create ("Correct AF & Make ratiometric image")

//default values:
firstt="0";lastt="1000";step="5";firstz="1";zslice="1000";proj1=1;shade="80";lut_table="Spectrum"; ratio_max=20; lut_yellow="Yellow";lut_cyan="Cyan";
bc_g_min="0";bc_g_max="500";bc_r_min="0";bc_r_max="200";px=2;af_corr_factor=2;


Dialog.addString("Lookup Table Ratio", lut_table)
Dialog.addNumber("Max range of the ratio",ratio_max)
Dialog.addNumber("Weight of AF image",af_corr_factor)
Dialog.addMessage("");

Dialog.addMessage ("Additional options")

//Dialog.addChoice("Output mode of ratio image:", newArray("RGB", "CYMK"));
Dialog.addCheckbox("Create channels images from lambda scan", false);
Dialog.addCheckbox("Auto-calibrate weight of the AF image", false);
Dialog.addCheckbox("Create Weighted Ratiometric Image", false);
Dialog.addCheckbox("Add scalebar", true)
Dialog.addCheckbox("Crop", false)
Dialog.addCheckbox("Bin 2x2", false);
Dialog.addCheckbox("Despeckle", false);
Dialog.addCheckbox("Calibrationbar", true);
Dialog.show();

//--------------------------
//recover the user input
//"Create weighted ratiometric image"
lut_table=Dialog.getString();
ratio_max=Dialog.getNumber();
ratio_max=ratio_max/10;
weight_af=Dialog.getNumber();
//"Additional options"

//comp_out_mode=Dialog.getChoice();
lambda=Dialog.getCheckbox();
calib=Dialog.getCheckbox();
wri=Dialog.getCheckbox();
scalebar=Dialog.getCheckbox();
Cropping=Dialog.getCheckbox();
bin=Dialog.getCheckbox();
desp=Dialog.getCheckbox();
calibrationbar=Dialog.getCheckbox();

print("end user input recovery");

//--------------------------
//set up stuff

//run("Set Measurements...", "  mean redirect=None decimal=3");    //measure only the mean gray value
setTool(0);        //Rectangle tool        
roiManager("reset");   //deletes all rois
//if (lastt==1000) { 
//		lastt=lengthOf(file_list);
//		} 
b_min=0;
b_max=250;
y_bg=0;
c_bg=0;


dirOut= dir + "Processed/"; 
File.makeDirectory(dirOut); 

print("end set up");

//--------------------------
// ask for and load ROI

if (calib==true){
	selectWindow(i_win);
	setSlice(1);     
	waitForUser("Please draw a roi in an area without fluorescence and then press ok");        
          //wait for user input
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Save",dir+"/rois.zip");
	}// has a bug that crops all the images unless cropping is also true
	
if (Cropping==true) {
	selectWindow(i_win);    
	waitForUser("Please draw a roi for the area to crop and then press ok");        
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Save",dir+"/rois.zip");
	}
	

selectWindow(i_win);   


//--------------------------------
// process

//setBatchMode(true);

		if (lambda==true) {
			lambda_to_channels();
			} else {
				name_channels();
				}
		
		correctAF();
		
	if (wri==true){
			WRI();
		} else {
			RI();
			}

//		print("ratiometric stack");
   		if (scalebar==true) {
		//	run("Set Scale...", "distance=50 known=2 pixel=1 unit=[micro m]");
			run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Lower Left] bold hide");
			//selectWindow();
			run("Save");
			}
//setBatchMode(false); 

run("Close All");

print("done!");
exit();


//--------------------------------------
// define function for creation of the CFP, YFP and AF images from a lambda scan of the confocal

function lambda_to_channels() {


selectWindow(i_win);


run("Make Substack...", "channels=1");
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff", dirOut+i_win + "_cfp.tif");
rename("cfp");


selectWindow(i_win);
run("Make Substack...", "channels=2");
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff", dirOut+i_win + "_yfp.tif");
rename("yfp");


selectWindow(i_win);
run("Make Substack...", "channels=3");
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff", dirOut+i_win + "_af.tif");
rename("af");
};

//--------------------------------------
// Alternative to lambda_to_channels. Splits a stack of 3 slices into 3 windows and calls the first CFP, the second YFP and the last AF

function name_channels() {

selectWindow(i_win);

run("Make Substack...", "channels=1");
rename("cfp");

selectWindow(i_win);
run("Make Substack...", "channels=2");
rename("yfp");

selectWindow(i_win);
run("Make Substack...", "channels=3");
rename("af");

};

//--------------------------------------
// define function for autofluorescence correction

function correctAF() {

//Correct autofluorescence
//linear unmixing using an image with an emission window with no fluorophores: "af"
//change to 32 buts and correct
//then save and close

//from the matlab code:
//af= afl -green  -afh;
//corr_g = abs(green - mean_p_g(1)* af - mean_p_g(2));

//slice 5 481, 6 492

selectWindow("af");
run("Multiply...", "value="+weight_af);
//run("Enhance Contrast", "saturated=0.35");
//selectWindow("yfp");
imageCalculator("Subtract create", "yfp","af");
selectWindow("Result of yfp");
saveAs("Tiff", dirOut+i_win_ne + "_yfp_AFcorr.tif");
rename("yfp_corr");
run("Enhance Contrast", "saturated=0.35");
imageCalculator("Subtract create", "cfp","af");
selectWindow("Result of cfp");
run("Enhance Contrast", "saturated=0.35");
saveAs("Tiff", dirOut+i_win_ne + "_cfp_AFcorr.tif");
rename("cfp_corr");
	

}; 


// define function for ratiometric image 
function RI() {

//create weigthed ratio from the images

selectWindow("yfp_corr"); 
run("32-bit");
run("Subtract...", "value=y_bg");
run("Enhance Contrast", "saturated=0.010");



selectWindow("cfp_corr"); 
run("32-bit");
run("Subtract...", "value=c_bg");
run("Enhance Contrast", "saturated=0.010");


imageCalculator("Divide create 32-bit image", "yfp_corr","cfp_corr");

windowRatio=getTitle();
selectWindow(windowRatio);
//print(windowRatio);
run(lut_table);
setMinAndMax(0, ratio_max);
selectWindow(windowRatio);


if (calibrationbar==true) {
	run("Calibration Bar...", "location=[Lower Right] fill=Black label=White number=3 decimal=1 font=12 zoom=1");
		
		}

saveAs("Tiff", dirOut+ i_win_ne+ "_ratio");
//end weighted ratio of images

};


// define function for weighted ratiometric image
 
function WRI() {

//create weigthed ratio from the images

selectWindow("yfp_corr"); 
run("32-bit");
run("Subtract...", "value=y_bg");
run("Enhance Contrast", "saturated=0.010");


selectWindow("cfp_corr"); 
run("32-bit");
run("Subtract...", "value=c_bg");
run("Enhance Contrast", "saturated=0.010");


imageCalculator("Divide create 32-bit image", "yfp_corr","cfp_corr"); 
windowRatio=getTitle();
selectWindow(windowRatio);
//print(windowRatio);
run(lut_table);

//separate ratio image into rgb components and multiply individually for the CFP image to get an intensity-weighted ratio
setMinAndMax(0, ratio_max);
run("RGB Color");
run("RGB Stack");
run("Stack to Images");

imageCalculator("Multiply create 32-bit stack", "Red","cfp_corr");
imageCalculator("Multiply create 32-bit stack", "Green","cfp_corr");
imageCalculator("Multiply create 32-bit stack", "Blue","cfp_corr");

run("Merge Channels...", "c1=[Result of Red] c2=[Result of Green] c3=[Result of Blue] create");
//selectWindow("Composite");
run("RGB Color");

//selectWindow(red);
//close();

run("Enhance Contrast", "saturated=0.010");


saveAs("Tiff", dirOut+ i_win_ne+ "_ratio");
//end weighted ratio of images

};

//----------------------------------------------------
// define function for projection, denoising,  fixing b&c, 

function preprocess() {

	
if (bin==true) {
	run("Bin...", "x=2 y=2 bin=Average");
	}

setMinAndMax(0, 1000);


//  for each channel it de-noises the images (you can choose), and over writes them 

 	if (desp==true) {
		setMinAndMax(b_min, b_max);
		run("Despeckle");
		}


// end of projection and preprocessing

};
