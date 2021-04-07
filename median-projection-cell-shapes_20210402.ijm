// This channel lets me create a synthetic image of cell background by creating a new image
// where I take the median intensity of 4 FISH channels.
// By taking the median of these 4 channels, bright FISH spots will be ignored, and the background autofluorescent
// signal from the cytoplasms of cells will be preserved
// This is to aid in the automated segmentation of cellular cytoplasms of 3D fluorescent images of FFPE or OCT tissues


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

		// Get dimensions of the image to know how many times to iterate
		getDimensions(w,h, c, nzs, f);
		
		// Create an empty Hyperstack with the same dimensions as the parent image
		// Make an empty hyperstack
	    // Has 5 channels
	    // Has 23 Z stacks
	    // Has 1 frame (time point)
	    newImage("HyperStack", "16-bit color-mode", w, h, c, nzs, f);

		// Iterate over each channel, iterate over each stack


		selectWindow(list[i]);

		// Iterate over channel
		for(channel=0; channel<c; channel++)
		//for(channel=0; channel<2; channel++)
		{
			//print(channel);

			// Iterate over each z stack
			for(zstack=0; zstack<nzs; zstack++)
			//for(zstack=0; zstack<2; zstack++)
			{
				selectWindow(list[i]);
				//print(zstack);
				run("Duplicate...", "duplicate channels="+channel+1 +" slices="+zstack+1);
				rename("tempStack");

				// Transform this image
				// Convert this image to a 32 bit image
				run("32-bit");
				// calculate pixel median
				median = getValue("Median");
				run("Subtract...", "value="+median);
				getStatistics(area, mean, min, max, std, histogram);
				run("Divide...", "value="+std);
				minVal = getValue("Min");
				// by subtracting a negative value, adding the absolute value of the min
				run("Subtract...", "value="+minVal);
				range = getValue("Max");
				run("Multiply...", "value="+65535/range);
				run("16-bit");

				// Paste into the empty hyperstack
				setPasteMode("Copy");
				run("Copy");
				selectWindow("HyperStack");
				Stack.setPosition(channel+1, zstack+1, 1)
				setPasteMode("Copy");
				run("Paste");

				selectWindow("tempStack");
				close();


			}

		}

		selectWindow("HyperStack");
		run("Duplicate...", "duplicate channels=2-5");
		rename("tempStack");


		selectWindow("HyperStack");
		close();

		selectWindow("tempStack");
		run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
		selectWindow("tempStack");
		run("Z Project...", "projection=Median");
		rename("medProj");
		run("16-bit");
		run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
		run("Magenta");
		// C9 prefix matches the style of the nuclei which are "C1_". Can change this output to something else later
		imgName = "C9_"+list[i];
		saveAs("Tiff", dir2+imgName);
		close();

		selectWindow("tempStack");
		close();


		selectWindow(list[i]);
		close();


	}


}

setBatchMode(false);




