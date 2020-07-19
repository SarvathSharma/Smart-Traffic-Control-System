% We are implementing a multiple object motion tracking system that
% MathWorks developed. Our initial/personal implmentation can be found in
% Tests/videoRendering

% Using Kalman Filter and Motion Based tracking to determine and track 
% vehicles

function MotionBasedMultiObjectTrackingExample()

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

   % Updates unidentified tracks as they move
   updateAssignedTracks();
   % Updates unidentified tracks as they move
   updateUnassignedTracks();
   % delete tracks for objects that leave frame
   deleteLostTracks();
   % Creates new tracks for objects that enter frame
   createNewTracks();
   
   displayTrackingResults();
end



%%%%%%%%%%%%% FUNCTION DEFINITIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial function to setup environment 
function videoObject = setupEnvironment()
    % Constructor function that initializes a new object to analyze
    
    % Video Reader method
    videoObject.videoReader = VideoReader('TrafficTest2.mp4');
    
    % We are using 2 video player methods, one for the dislaying and one 
    % for the foreground detector
    videoObject.videoPlayer = vision.VideoPlayer('Position', ...
                                                [740, 400, 700, 400]);
    videoObject.foregroundPlayer = vision.VideoPlayer('Position', ...
                                                [20, 400, 700, 400]);
                                            
    % Now we need to just add the methods for the Foreground Detector and
    % Blob Analysis of the images
    videoObject.detector = vision.ForegroundDetector('NumGaussians', 3,...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
    videoObject.blobAnalyser = vision.BlobAnalysis('AreaOutputPort', ...
        true, 'BoundingBoxOutputPort', true, 'CentroidOutputPort', ...
        true, 'MinimumBlobArea', 400, 'ExcludeBorderBlobs', true);
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
 function [centroids, bboxes, filteredImage] = detectObjects(singleFrame)
 
    % Detect foreground
    filteredImage = videoObject.detector.step(singleFrame);
    % Apply morphological operations to remove noise and fill in holes
    filteredImage = imopen(filteredImage, strel('rectangle', [3,3]));
    filteredImage = imclose(filteredImage, strel('rectangle', [15, 15]));
    filteredImage = imfill(filteredImage, 'holes');

    % Perform blob analysis to find connected components
    [~, centroids, bboxes] = videoObject.blobAnalyser.step(filteredImage);

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
        cost(singleTrack, :) = distance(...
            trackStruct(singleTrack).kalmanFilter, centroids);
    end
    
    % Solve the assignment problem using built in function.
    costOfNonAssignment = 20; % This number is experimental
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end

% This function updates and corrects the location estimation we make for
% the tracks we detect
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

% This function makes sure unassigned tracks are invisible
function updateUnassignedTracks()
    % for each track in the unassigned tracks
    for track = 1:length(unassignedTracks)
        % get the unassigned track
        unassignedTrack = unassignedTracks(track);
        % update the age of the unassigned track
        trackStruct(unassignedTrack).age = ...
            trackStruct(unassignedTrack).age + 1;
        % mark unassigned track as invisible
        trackStruct(unassignedTrack).consecutiveInvisibleCount = ...
            trackStruct(unassignedTrack).consecutiveInvisibleCount + 1;
    end
end

% Function deletes tracks that have been invisible for too many 
% consecutive frames
function deleteLostTracks()
    if isempty(trackStruct)
        return;
    end

    invisibleForTooLong = 20;
    ageThreshold = 8;

    % Compute the fraction of the track's age for which it was visible.
    ages = [trackStruct(:).age];
    totalVisibleCounts = [trackStruct(:).totalVisibleCount];
    visibility = totalVisibleCounts ./ ages;

    % Find the indices of 'lost' tracks.
    lostInds = (ages < ageThreshold & visibility < 0.6) | ...
        [trackStruct(:).consecutiveInvisibleCount] >= invisibleForTooLong;

    % Delete lost tracks.
    trackStruct = trackStruct(~lostInds);
 end
 
 % This function creates new tracks from unassigned detections. 
 % Assume that any unassigned detection is a start of a new track.
  function createNewTracks()
    centroids = centroids(unassignedDetections, :);
    bboxes = bboxes(unassignedDetections, :);
    
    for i = 1:size(centroids, 1)

        centroid = centroids(i,:);
        bbox = bboxes(i, :);

        % Create a Kalman filter object.
        kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
            centroid, [200, 50], [100, 25], 100);

        % Create a new track.
        newTrack = struct(...
            'id', nextId, ...
            'bbox', bbox, ...
            'kalmanFilter', kalmanFilter, ...
            'age', 1, ...
            'totalVisibleCount', 1, ...
            'consecutiveInvisibleCount', 0);

        % Add it to the array of tracks.
        trackStruct(end + 1) = newTrack;

        % Increment the next id.
        nextId = nextId + 1;
    end
end

%This function draws a bounding box and label ID for each track ...
% on the video frame and the foreground mask. 
%It then displays the frame and the mask in their respective video players
function displayTrackingResults()
    % Convert the frame and the mask to uint8 RGB.
    singleFrame = im2uint8(singleFrame);
    filteredImage = uint8(repmat(filteredImage, [1, 1, 3])) .* 255;

    minVisibleCount = 8;
    if ~isempty(trackStruct)

        % Noisy detections tend to result in short-lived tracks.
        % Only display tracks that have been visible for more than
        % a minimum number of frames.
        reliableTrackInds = ...
            [trackStruct(:).totalVisibleCount] > minVisibleCount;
        reliableTracks = trackStruct(reliableTrackInds);

        % Display the objects. If an object has not been detected
        % in this frame, display its predicted bounding box.
        if ~isempty(reliableTracks)
            % Get bounding boxes.
            bboxes = cat(1, reliableTracks.bbox);

            % Get ids.
            ids = int32([reliableTracks(:).id]);

            % Create labels for objects indicating the ones for
            % which we display the predicted rather than the actual
            % location.
            labels = cellstr(int2str(ids'));
            predictedTrackInds = ...
                [reliableTracks(:).consecutiveInvisibleCount] > 0;
            isPredicted = cell(size(labels));
            isPredicted(predictedTrackInds) = {' predicted'};
            labels = strcat(labels, isPredicted);

            % Draw the objects on the frame.
            frame = insertObjectAnnotation(singleFrame, 'rectangle', ...
                bboxes, labels);

            % Draw the objects on the mask.
            filteredImage = insertObjectAnnotation(filteredImage, 'rectangle', ...
                bboxes, labels);
        end
    end

    % Display the mask and the frame.
    videoObject.videoPlayer.step(filteredImage);
    videoObject.foregroundPlayer.step(singleFrame);
  end
end