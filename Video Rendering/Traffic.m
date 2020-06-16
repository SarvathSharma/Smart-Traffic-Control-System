clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest2.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating number of frames

% Train model using the first 150 frames
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 150);

% Call to calibrating function
calibrating(trafficVid, foregroundDetector.NumTrainingFrames,...
    foregroundDetector);

% make temp directory to store video, not sure if this is saved after running, 
% if you can't find the folder I can try saving it somewhere solid after the video is made
% vidDir = videoOutput;
% mkdir(vidDir)
% make sub folder for video frames
%mkdir(vidDir,'images')

%Reset Video
trafficVid = VideoReader('TrafficTest2.mp4');

%Stack Implementation to count cars
old_frame = 0;
total_cars = 0;

for k = 1 : nframes
    
    % Read frame and get data
    % Using the size of the image screen, display a border line on the
    % center of the image
    singleFrame = readFrame(trafficVid);
    [y, x, z] = size(singleFrame);
    grid on
    x1 = x/4; y1 = y/4; x2 = (3*x)/4; y2 = (3*y)/4;
    singleFrame = insertShape(singleFrame, 'Line', [x1 y1 x2 y2], ...
        'LineWidth', 2, 'Color', 'black');
    
    % Inital image filtering
    foreground = step(foregroundDetector, singleFrame);
    
    % Convert to grayscale to do morphological processing
    newImgs = imageEnhancement(foreground);
    
    % Detect car using blob analysis and displays new image, returns new
    % total number of cars data in an array
    new_data = vehicleDetection(newImgs, singleFrame, total_cars, ...
        old_frame);
    
    %Updating data
    total_cars = new_data(1);
    old_frame = new_data(2);
    

    % name images from img001.jpg to imgN.jpg
    % filename = [sprintf('03%',k) '.jpg'];
    % fullname = fullfile(vidDir.'images',filename);

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
        newIMG = insertText(singleFrame,position,'Calibrating...',...
            'FontSize',18,'BoxColor', box_color,'TextColor','white');
        
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

function new_data = vehicleDetection(input, frame, oldTotal, oldFrameNumCars)   

    % Performs blob analysis in order to create a green box around cars
    % Then count the number of boxes which should be the cars
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', false, ...
        'MinimumBlobArea', 250, 'ExcludeBorderBlobs', true);
    bbox = step(blobAnalysis, input);
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    currFrameNumCars = size(bbox, 1);
    
    %Updating total_number of cars count
    if currFrameNumCars >= oldFrameNumCars
        
        new_data(1) = oldTotal + (currFrameNumCars - oldFrameNumCars);
        new_data(2) = currFrameNumCars;
        
    else
        
        new_data(1) = oldTotal;
        new_data(2) = currFrameNumCars;
        
    end
   
    result = insertText(result, [10 10], new_data(1),...
                'BoxOpacity', 1, 'FontSize', 15);
    imshow(result);
    
end