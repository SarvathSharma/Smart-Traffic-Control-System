% Using Kalman Filter and Motion Based tracking to determine and track 
% vehicles

clc;	% Clear command window.
clear;	% Delete all variables.

% Create new object to analyze
videoObject = setupEnvironment();
% Creates an empty array of structs with properties to track
trackStruct = initializeTracks();

nextId = 1; % ID of the next track

% Detection and Vehicle count for every frame in the video
while hasFrame(videoObject.videoReader)
   % Stores a single frame of the video
   singleFrame = readFrame(videoObject.videoReader);
   % Performs image filtering and blob analysis, then stores the centroids,
   % bboxes and the filtered Image
   [centroids, bboxes, filteredImage] = detectObjects(singleFrame);
   % Predicts the new location of deteced objects
   predictLocation();
   % This function decides whether or not to use the predicted location
   % based on confidence of detection and minimized cost
   [assignments, unassignedTracks, unassignedDetections] = ... 
       detectionToTrackAssignment();
   
   updateAssignedTracks();
end



%%%%%%%%%%%%% FUNCTION DEFINITIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial function to setup environment 
function initialObj = setupEnvironment()
    % Constructor function that initializes a new object to analyze
    
    % Video Reader method
    initialObj.videoReader = VideoReader('TrafficTest2.mp4'); 
    
    % We are using 2 video player methods, one for the dislaying and one 
    % for the foreground detector
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
    % Create an empty array of tracks
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


% This function is responsible for predicting where the object will be of
% it was covered by an external object (bridge, overpass, etc)
function predictLocation() 
    % By using the Kalman Filter (by MathWorks) we can predict the
    % location of each centroid in the given frame. We just need to update
    % the bbox around it to show that we have a idea as to where it is
    for vehicle = 1:length(trackStruct)
       boundaryBox = trackStruct(vehicle).bbox;
       
       % Use the Kalman filter to track the object
       % We are assuming the velocity is constant so the prediction will
       % follow that given speed
       predictNextPoint = predict(trackStruct(vehicle).kalmanFilter);
       
       % Update the bounday box so that it follows the centroid
       predictNextPoint = int32(predictNextPoint) - boundaryBox(3:4)/2;
       trackStruct(vehicles).bbox = [predictNextPoint, boundaryBox(3:4)];
    end
end

% This function decides whether or not to use the predicted location
% based on confidence of detection and minimized cost
function [assignments, unassignedTracks, unassignedDetections] = ... 
    detectionToTrackAssignment()
    
    totalTracks = length(trackStruct); % This is what we currently track
    totalDetections = size(centroids, 1);  % What can be added to track
    
    % Compute the cost of assigning each detection to each track.
    cost = zeros(totalTracks, totalDetections);
    for singleTrack = 1:totalDetections
        cost(singleTrack, :) = distance(trackStruct(singleTrack).kalmanFilter, centroids);
    end
    
    % Solve the assignment problem using built in function.
    costOfNonAssignment = 20; % This number is experimental
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end

% This function updates and corrects the location estimation we make for the tracks we detech
% and updates the age of the tracks accordingly
function updateAssignedTracks()
    % finds number of tracks to correct
    assignedTracks = size(assignments, 1);
    for track = 1:assignedTracks
        % gets id of current track
        trackIdx = assignments(track, 1);
        % gets id of the detection for the track
        detectionIdx = assignments(track, 2);
        % gets the centroid from detection
        centroid = centroids(detectionIdx, :);
        % gets the box drawn for the detection
        bbox = bboxes(detectionIdx, :);

        % With the new centroid, corrects and updates the previous track
        correct(trackStruct(trackIdx).kalmanFilter, centroid);

        % We can not replace the predicted bound box with the detected one
        trackStruct(trackIdx).bbox = bbox;

        % The track gains age for each update
        trackStruct(trackIdx).age = trackStruct(trackIdx).age + 1;

        % The visibility of the track was updated so we update the count
        trackStruct(trackIdx).totalVisibleCount = ...
            trackStruct(trackIdx).totalVisibleCount + 1;
        % The invisible count must be set to 0 now that we have corrected
        % the prediction
        trackStruct(trackIdx).consecutiveInvisibleCount = 0;
    end
end

