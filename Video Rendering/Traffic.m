clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest2.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating how many frames are in the video

%Train model using the first 150 frames
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 150);

for k = 1 : nframes
    
    singleFrame = readFrame(trafficVid); %Read frame
    
    foreground = step(foregroundDetector, singleFrame); %Inital image filtering
    
    % Convert to grayscale to do morphological processing.
    I = imageEnhancement(foreground);
    
    I = vehicleDetection(I, singleFrame); % Blob analysis
    
    imshow(I); %The first 150 outputs are used for training purposes

end

function img = imageEnhancement(input)
    
    %The below is commented since i've added the Vision library for inital
    %filtering
    
    % Generate binary image
    %img = rgb2gray(input);
    %binaryImage = imbinarize(img, ...
    %    'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.52);
    %binaryImage = ~binaryImage;
    %binaryImage = bwareaopen(binaryImage, 175); % Removes small objects
    
    
    % After initial filtering remove noise
    se1 = strel('disk', 1);
    se2 = strel('disk', 2);
    imgOpen = imclose(input, se1);
    imgClose = imopen(imgOpen, se2);
    imgFill = imfill(imgClose, 'holes');
    clearBorders = imclearborder(imgFill);
    se3 = strel('square', 20);
    finalImg = imdilate(clearBorders, se3);
    img = finalImg;
end

function img = vehicleDetection(input, frame)   
    
    %Performs blob analysis in order to create a green box around cars
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 250, 'ExcludeBorderBlobs', true);
    bbox = step(blobAnalysis, input);
    img = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
%     text(10,10,strcat('\color{black}Vehicles Detected:', ...
%         )
end