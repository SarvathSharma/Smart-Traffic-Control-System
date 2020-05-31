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
    img = rgb2gray(input);
    binaryImage = imbinarize(img, ...
        'adaptive','ForegroundPolarity','dark', 'Sensitivity', 0.4);
    binaryImage = ~binaryImage;
    binaryImage = bwareaopen(binaryImage, 150); % Removes small objects
    sedisk = strel('disk', 2);  
    binaryImage = imopen(binaryImage, sedisk); % Removes noise
    binaryImage = imfill(binaryImage, 'holes');
    binaryImage = imclearborder(binaryImage);
    img = binaryImage;
end


function img = vehicleDetection(input, frame)
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 250);
    bbox = step(blobAnalysis, input);
    img = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
end