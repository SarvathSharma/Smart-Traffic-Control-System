clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest2.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating number of frames

% Train model using the first 150 frames
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 150);

% Call to calibrating function
calibrating(trafficVid, foregroundDetector.NumTrainingFrames, foregroundDetector);

% make temp directory to store video, not sure if this is saved after running, 
% if you can't find the folder I can try saving it somewhere solid after the video is made
% vidDir = videoOutput;
% mkdir(vidDir)
% make sub folder for video frames
%mkdir(vidDir,'images')

%Reset Video
trafficVid = VideoReader('TrafficTest2.mp4');

for k = 1 : nframes
    
    %Read frame
    singleFrame = readFrame(trafficVid);
    
    % Inital image filtering
    foreground = step(foregroundDetector, singleFrame);
    
    % Convert to grayscale to do morphological processing
    newImgs = imageEnhancement(foreground);
    
    % name images from img001.jpg to imgN.jpg
    % filename = [sprintf('03%',k) '.jpg'];
    % fullname = fullfile(vidDir.'images',filename);

    detectedVehicles = vehicleDetection(newImgs, singleFrame);
    imshow(detectedVehicles);

    % name and write the file properly
    % img = detectedVehicles;
    % imwrite(img,fullname);
    
end

% get all images written
% imageNames = dir(fullfile(vidDir,'images','*.jpg'));
% imageNames = {imageNames.name}';

% convert to video
% outputVideo = VideoWriter(fullfile(vidDir, 'traffic_out.mp4'));
% outputVideo.FrameRate = trafficVid.FrameRate;

function calibrating(video, trnframes, model)
  
    for i=1 : trnframes
        
        % Read Frame
        singleFrame = readFrame(video);
        
        % Train model
        step(model, singleFrame);
        
        %Insert Text
        position = [10,10];
        box_color = 'black';
        newIMG = insertText(singleFrame,position,'Calibrating...','FontSize',18,'BoxColor',...
        box_color,'TextColor','white');
        
        %Output video with calibrating text in top left corner
        imshow(newIMG);
        
    end


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

function result = vehicleDetection(input, frame)   

    % Performs blob analysis in order to create a green box around cars
    % Then count the number of boxes which should be the cars
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 250, 'ExcludeBorderBlobs', true);
    bbox = step(blobAnalysis, input);
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    numberOfVehicles = size(bbox, 1);
    result = insertText(result, [10 10], numberOfVehicles,...
                'BoxOpacity', 1, 'FontSize', 15);
end

