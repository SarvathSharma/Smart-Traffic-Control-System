clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating how many frames are in the video

for k = 1 : nframes
    singleFrame = readFrame(trafficVid);
    % Convert to grayscale to do morphological processing.
    I = imageEnhancement(singleFrame);
    I = vehicleDetection(I, singleFrame); % Blob analysis
    imshow(I);
end

function img = imageEnhancement(input)
    % Generate binary image
    img = rgb2gray(input);
    binaryImage = imbinarize(img, ...
        'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.52);
    binaryImage = ~binaryImage;
    binaryImage = bwareaopen(binaryImage, 175); % Removes small objects
    % Removes noise
    se1 = strel('disk', 1);
    se2 = strel('disk', 2);
    imgOpen = imclose(binaryImage, se1);
    imgClose = imopen(imgOpen, se2);
    imgFill = imfill(imgClose, 'holes');
    clearBorders = imclearborder(imgFill);
%     str = strel('square', 20);
%     finalImg = imdilate(clearBorders, str);
    img = clearBorders;
end

function img = vehicleDetection(input, frame)      
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 250, 'ExcludeBorderBlobs', true);
    bbox = step(blobAnalysis, input);
    img = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
%     text(10,10,strcat('\color{black}Vehicles Detected:', ...
%         )
end