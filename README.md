# Image Processing and Computer Vision :computer:
**Change detection with Matlab**

**1-PROJECT DEFINITION**

***1.1 Objective***

Application should detect objects (intruders) that do not belong to a static reference scene (background) and establish which of such objects are persons.

***1.2 Functional Specifications***

Based on a change detection algorithm and additional suitable processing steps, the system should provide the following outputs:

- Graphical Output: in each frame (but, possibly, those deployed for initialization purposes) the system should show either the labeled blobs (as illustrated in the left picture below) or the labeled contours (right picture below) corresponding to detected objects.

- Text Output: the system should create an output text file reporting, for each frame, the number of detected objects, the values of the associated blob features and the classification into either “person” or “other”. The table below shows an example of how such a kind of output might be organized.

**2-Studies On Project**

All coding actions are handled in MATLAB environment. At first, it is necessary to decide on change detection strategy. There are two main approaches:
1.	Two-frame difference
2.	Three-frame difference
Since three-frame difference approach does not solve foreground aperture problem and stationary object problem, the studies are based on the two-frame difference approach. However, use of two consecutive frames results with ghosting effect, and does not solve foreground aperture problem.
In order to solve these issues, background subtraction method is used. Thus, still two frames are subtracted but the first frame is not the previous frame anymore. An initialized and updated background frame is our reference.

***2.1 Background Initialization***

According to uncertainty of frames in real-time video source, it is necessary to calculate an initial background frame

***2.2 Binarization of Change Detection Frame***

After taking difference between current frame and background frame, threshold level has been calculated to get a black-and-white image.
At first, histogram of the gray-scale difference image has been calculated. Then, in order to avoid light level change effect, bright pixels (low level intensities) are saturated

***2.3 Morphological Operations***

The first operation on the binary image is to eliminate noisy areas. The operation is called area opening which removes from a binary image all connected components (objects) that have fewer than 25 pixels. The function makes opening operation with respect to white background. Thus, it is used as closure in this part since our background is black. The operation uses 8-neighbourhood by default and involves dilation followed by erosion in consideration of black background.

Beside this MATLAB function, erosion and dilation algorithms have been coded. Since the codes of MATLAB toolbox are compiled in C, their execution are faster.

The next operation aims to close the holes inside the foreground images in order to maintain the detected object. Thus, area opening function has been applied to the image complement. After a dilation process, the area closing operation is repeated by increasing pixel size.

***2.4 	Background Update***

The next operation is to update the background frame in order to handle the changes in exposure. Thus, the background pixel (black pixel) indexs of the last binary frame and current background frame are taken into account by a parameter alpha.

***2.5 Labeling***

The aim of this step is to label the connected foreground objects by assigning numbers. The assigned numbers starts from 1 and ascends monotinically

In addition to this part, color mapping has been applied to the labeled object in order to make them more distinguishable. The map is generated as an intensity level by adding a bias and multiplying a gain with the label numbers.

***2.6 Blob Features***

As several blob features are required to be displayed, area, perimeter, height, weight and classification of the objects are determined.
Area is calculated by counting same labeled pixels. Perimeter is calculated by counting same labeled 4 neighborhood contour pixels. Height is calculated by subtracting the maximum and minimum row indexes of same labeled pixels. Weight is calculated by subtracting the maximum and minimum column indexes of same labeled pixels. At last, object are classified by comparing area features of labeled objects with a threshold 
