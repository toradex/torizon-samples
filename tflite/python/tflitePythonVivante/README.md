# Tensorflow Lite Python Sample

**Before using the sample remember to unzip the build.zip and the 
cats_and_dogs_filtered.zip files**. You can do it with the following commands:

- `unzip build.zip`

- `unzip dogs_and_cats_filtered.zip`


This sample shows an example using Tensorflow Lite with hardware acceleration 
on the IMX8 SoCs with Vivante GPU. 

In this example an inference is performed to classify dogs and gats, showing 
the time it took to perform each inference, and in the end how many inferences 
it performed per second (Mean image/s).