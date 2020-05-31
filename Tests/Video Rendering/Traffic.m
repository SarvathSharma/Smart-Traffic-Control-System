clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating how many frames are in the video

for k = 1 : nframes
    singleFrame = readFrame(trafficVid);
    % Convert to grayscale to do morphological processing.
    I = imageEnhancement(singleFrame);
end


function img = imageEnhancement(input)
    img = rgb2gray(input);
    binaryImage = imbinarize(img, ...
        'adaptive','ForegroundPolarity','dark', 'Sensitivity', 0.4);
    binaryImage = ~binaryImage;
    binaryImage = bwareaopen(binaryImage, 150);
    sedisk = strel('disk', 3);
    binaryImage = imopen(binaryImage, sedisk);
    binaryImage = imfill(binaryImage, 'holes');
    binaryImage = imclearborder(binaryImage);
    imshow(binaryImage);
end