clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating how many frames are in the video

for k = 1 : nframes
    singleFrame = read(trafficVid, k);

    % Convert to grayscale to do morphological processing.
    I = rgb2gray(singleFrame);
    
    
end


% Not yet tested (Using Computer Vision Toolbox)
% Code was from: https://www.mathworks.com/help/vision/examples/object-counting.html

% Making a blob analysis system to count the number of objects
% in the video
hBlob = vision.BlobAnalysis('AreaOutputPort', false, ...
                            'BoundingBoxOutputPort', false, ...
                            'OutputDataType', 'single');
% Create a system object to display the video
outputVideo = vision.VideoPlayer('Name', 'Number of Vehicles');
outputVideo.Position(3:4) = [650 350];

% Check the frames of the video and determine the vehicles detected
while hasFrame(trafficVid)
    grayScaled = rgb2gray(readFrame(trafficVid));
    img = imtophat(grayScaled, strel('square', 18));
    img = imopen(img, strel('rect', [15 3]));
    threshold = multithresh(img);
    binaryImage = img > threshold;
    detectionPoints = step(hBlob, binaryImage);
    
    % Count and display the number of detections
    vehicleCount = int32(size(detectionPoints, 1));
    text(15,15, strcat('\color{green}Objects Found:', ...
        num2str(vehicleCount)))
end