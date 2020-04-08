%% Clear and Close Section
clc % Clear command window
clear all % Clear workspace
close all % Close figures

%% Load Video

% Get video name and path
[fileName,pathName] = uigetfile('*.avi','Choose your video file...');

% Generate video object
videoFile = VideoReader([pathName fileName]);

%% Backgroun Initialization
bckFrNo = 51;   % Set number of frames to generate background image

% Allocate memory for multi-frame matrix
% This initial matrix includes zeros with 8-bit unsigned integer data type.
% The dimensions of matrix are set w.r.t. frame hight, frame width and
% number of initial frames.
initialFrames = uint8(zeros(videoFile.Height,videoFile.Width,bckFrNo));

for cnt = 1:bckFrNo % Scan images from the first frame to defined frame number
    % Fill multi dimensional matrix by frames of video file on grayscale mode
    initialFrames(:,:,cnt) = rgb2gray(read(videoFile,cnt));
end

% Allocate memory for background image
% This initial matrix includes zeros with 8-bit unsigned integer data type.
baseFrame = uint8(zeros(videoFile.Height,videoFile.Width));

for cnr = 1:videoFile.Height % Scan for each row of frames
    for cnc = 1:videoFile.Width % Scan for each column of frames
        % Calculate median of initial frames for each pixel
        baseFrame(cnr,cnc) = median(initialFrames(cnr,cnc,:));
    end
end

%% Algorithm Parameters
frameCounter = 400; % Holds frame counter
alpha = 0.01; % background update parameter
min_t = 30; % minimum threshold value
classTreshold = 1500; % area threshold to differ objects w.r.t. label areas
tSaturate = 120; % threshold saturation level
dlKer = true(20,10); % initial set for dilation kernel which is 20 by 10 logical 1 matrix

% Makes the corners of kernel zero
dlKer([1 end],[1:3 end-2:end])=false; 
dlKer([2:3 end-2:end-1],[1:2 end-1:end])=false;
dlKer([4:6 end-3:end-5],[1 end])=false;

rgbMap = [0.3 0.8 0.9]; % RGB color base set for labels

%% Detect change

% Allocate memory for colored label frame
% This initial matrix includes zeros with 8-bit unsigned integer data type.
lbFrameRGB = uint8(zeros(videoFile.Height,videoFile.Width,3));

% Calculate all features for each frame
while frameCounter <= videoFile.NumberOfFrames
    clc; % Clear command window
    
    % Displays the frame number on command window
    disp(['Frame No: ' num2str(frameCounter)]); 
    
    % Acquire new frame from the video object
    newFrame = rgb2gray(read(videoFile,frameCounter)); 
    
    % Calculate absolute value of the difference between new frame and background
    diffFrame = uint8(abs(int16(newFrame) - int16(baseFrame))); 
    
    % Calculate histogram vector for the saturated difference frame
    % Saturation is operated in order to get rid of sudden brightness
    % change effects. Thus, high intensity values are not considered on
    % automatic threshold calculation
    indx = histCV(saturateVector(diffFrame,tSaturate));
    
    % Greyscale to Black-White threshold calculation
    T = otsuThreshold(indx); 
    
    if T < min_t % Detect low treshold values
        T = min_t; % Set minimum threshold to a defined number to prevent noises
    end
    
    % Form greyscale image to black-white (BW) image (logical 1 and 0 matrix)
    BW_Frame = (diffFrame > T); 
    
    % Eliminate the objects smaller than 25 pixels
    BW_Frame = bwareaopen(BW_Frame,25); 
    
    % Connecting the separate parts of the same object and filling holes
    % Area closing operation for holes smaller than 500 pixels
    BW_Frame = imcomplement(bwareaopen(imcomplement(BW_Frame),500));
    
    % Object closing operation with dilation kernel
    BW_Frame = imclose(BW_Frame,dlKer); 
    
    % Area closing operation for holes smaller than 1000 pixels
    BW_Frame = imcomplement(bwareaopen(imcomplement(BW_Frame),1000));
    
    % Background update
    baseFrame(BW_Frame==0) = alpha * newFrame(BW_Frame==0)...
        + (1 - alpha) * baseFrame(BW_Frame==0);
    
    % Labeling the BW frame with 8-pixel neighborhood
    lbFrame = uint8(bwlabel(BW_Frame,8)); 
    
    % Generating the perimeters of the objects with 4-pixel neighborhood
    perimFrame = bwperim(BW_Frame,4); 
    
    % Allocation of the frame that includes labeled perimeters
    % This initial matrix includes zeros with 8-bit unsigned integer data type.
    perimIndx = uint8(zeros(videoFile.Height,videoFile.Width));
    
    % Assigning the same labels to the perimeters of the objects
    perimIndx(perimFrame ~= 0) = lbFrame(perimFrame ~= 0);
    
    labeledFrame = single(lbFrame);
    
    % Increasing the level of foreground objects' labels
    labeledFrame(labeledFrame ~= 0) = labeledFrame(labeledFrame ~= 0) + 50;
    
    labeledFrame = labeledFrame / max(labeledFrame(:)); % Normalize the labels
    
    % Applying the colormap to the labels
    lbFrameRGB(:,:,1) = uint8(rgbMap(1)*labeledFrame*256);
    lbFrameRGB(:,:,2) = uint8(rgbMap(3)*labeledFrame*256);
    lbFrameRGB(:,:,3) = uint8(rgbMap(3)*labeledFrame*256);
    
    % Shows the original frame and labeled frame
    subplot(1,2,1); imshow(newFrame);
    subplot(1,2,2); imshow(lbFrameRGB);
    
    totArea = sum(BW_Frame(:)); % Calculate the area of all foreground objects
    tempLabels = unique(lbFrame); % Define the union set of labels
    tempLabels(tempLabels == 0) = []; % Get non zero label numbers
    Labels = (1:length(tempLabels))'; % Set general label vector starting from 1
    Areas = uint16(zeros(length(Labels),1)); % Initialize area vector of objects
    Perimeters = uint16(zeros(length(Labels),1)); % Initialize perimeter vector of objects
    Heights = uint16(zeros(length(Labels),1)); % Initialize height vector of objects
    Widths = uint16(zeros(length(Labels),1)); % Initialize width vector of objects
    Classes = cell(length(Labels),1); % Initialize class vector of objects
    for lbCnt = Labels' % Scan objects for each label
        [rwN,clN] = find(lbFrame == Labels(lbCnt)); % Acquire the positions of the choosen label object pixels
        Heights(lbCnt) = max(rwN) - min(rwN); % Calculate the hight of the object
        Widths(lbCnt) = max(clN) - min(clN); % Calculate the width of the object
        lbFrame(lbFrame == tempLabels(lbCnt)) = Labels(lbCnt); % Seting the generalized label number
        Areas(lbCnt) = numel(find(lbFrame == Labels(lbCnt))); % Calculate the area of the object
        
        % Classification of the object w.r.t. object area
        if Areas(lbCnt) >= classTreshold
            Classes{lbCnt} = 'Person';
        else
            Classes{lbCnt} = 'Other';
        end
        
        perimIndx(perimIndx == tempLabels(lbCnt)) = Labels(lbCnt); % Seting the generalized label numbers to perimeter frame
        Perimeters(lbCnt) = numel(find(perimIndx == Labels(lbCnt))); % Calculate the perimeter of the object
    end
    tbl = table(Labels,Areas,Perimeters,Heights,Widths,Classes) % Set and show the blob features' table
    frameCounter = frameCounter + 1; % Increment the frame counter
    pause(2); %pause(1/videoFile.FrameRate); % Pause the code according to video frame rate
end