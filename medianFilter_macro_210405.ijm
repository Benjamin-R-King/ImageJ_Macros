// This macro applies a median filter to images in the source directory
// We noticed that hot pixels on one of our cameras was leading to spurious FISH spot detections
// By applying a median filter with a radius of 1, we are able to preserve true FISH spots, but eliminate signal from hot pixels


// Get the directory where images live
dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory ");

list = getFileList(dir1);

setBatchMode(true);
for (i=0; i<list.length; i++)
//for (i=0; i<5; i++)
{
	// Print the name of everything in this input folder
	//print(list[i]);

	// Only process the files that have a ".tif" or ".tiff" extension
	if( (indexOf(list[i],".tif") != -1) || (indexOf(list[i],".TIF") != -1))
	{
		// Open the .tif or .tiff file
		open(dir1+list[i]);
		print(list[i]);
		run("Median...", "radius=1");

		imgName = substring(list[i],0,lengthOf(list[i])-4) + "_filtered.tif";
		saveAs("Tiff", dir2+imgName);
		close();
	}
}

setBatchMode(false);




