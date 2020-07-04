% Using Kalman Filter and Motion Based tracking to determine and track 
% vehicles

clc;	% Clear command window.
clear;	% Delete all variables.


videoObject = setupEnvironment();   % Create new object to analyze

trackStruct = initializeTracks();   % Creates an empty array of structs with properties to track

nextId = 1; % ID of the next track

% Detection and Vehicle count for every frame in the video
while hasFrame(videoObject.videoReader)
   singleFrame = readFrame(videoObject.videoReader); % Stores a single frame of the video
   [centroids, bboxes, filteredImage] = detectObjects(singleFrame); % Performs image filtering and blob analysis, then stores the centroids, bboxes and the filtered Image
    
    
    
end










%%%%%%%%%%%%% FUNCTION DEFINITIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial function to setup environment 
function initialObj = setupEnvironment()
    % Constructor function that initializes a new object to analyze
    
    % Video Reader method
    initialObj.videoReader = VideoReader('TrafficTest2.mp4'); 
    
    % We are using 2 video player methods, one for the dislaying and one for the
    % foreground detector
    initialObj.videoPlayer = vision.VideoPlayer('Position', ...
                                                [80, 300, 550, 400]);
    initialObj.foregroundPlayer = vision.VideoPlayer('Position', ...
                                                [740, 400, 700, 400]);
                                            
    % Now we need to just add the methods for the Foreground Detector and
    % Blob Analysis of the images
    initialObj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
    initialObj.blobAnalyser = vision.BlobAnalysis('AreaOutputPort', ...
        false, 'BoundingBoxOutputPort', true, 'CentroidOutputPort', ...
        false, 'MinimumBlobArea', 250, 'ExcludeBorderBlobs', true);
end


% Function creates an empty array of structs with properties to track
function trackStruct = initializeTracks()
    % create an empty array of tracks
    trackStruct = struct(...
        'id', {}, ...
        'bbox', {}, ...
        'kalmanFilter', {}, ...
        'age', {}, ...
        'totalVisibleCount', {}, ...
        'consecutiveInvisibleCount', {});
end

% Function performs image filtering and blob analysis
 function [centroids, bboxes, filteredFrame] = detectObjects(frame)

        % Detect foreground.
        foregroundFrame = videoObject.detector.step(frame);

        % Apply morphological operations to remove noise and fill in holes.
        filteredFrame = imopen(foregroundFrame, strel('rectangle', [3,3]));
        filteredFrame = imclose(filteredFrame, strel('rectangle', [15, 15]));
        filteredFrame = imfill(filteredFrame, 'holes');

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = videoObject.blobAnalyser.step(filteredFrame);
 end


