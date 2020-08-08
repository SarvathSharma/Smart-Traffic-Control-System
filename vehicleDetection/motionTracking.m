% We are implementing a multiple object motion tracking system that
% MathWorks developed. Our initial/personal implmentation can be found in
% Tests/videoRendering

% Using Kalman Filter and Motion Based tracking to determine and track
% vehicles

%function runs video detection with the assitance of mini helper functions
function motionTracking()
    % Create new object to analyze
    videoObj = setupSystem();

    % Creates an empty array of structs with properties to track
    trackArr = initializeTracks(); % Create an empty array of tracks.

    nextId = 1; % ID of the next track

    % Initial data of the number of vehicles
    global oldFrame;
    global totalCars;
    oldFrame = 0;
    totalCars = 0;
    
    % Number of training frames
    nTrainingFrames = 150;

    %Stores total frames in video without training frames
    nFrames = videoObj.reader.NumFrames - nTrainingFrames;
    
    if nFrames < 200
        nFramesStr = num2str(nFrames)
        warningStr = "Not enough frames in video. Contains following number of frames: "
        nFramesStr = append(warningStr, nFramesStr)
        ME = MException("MyVideo:notEnoughFrames", nFramesStr, nFrames)
        throw(ME)
    end

    % Call to calibrating function 
    calibrating(nTrainingFrames);

    %Keeps count of frames
    intervalCounter = 0;
    
    %This should be changed to 108000 for production ( 30 minutes )
    numFramesPerInterval = 100;

    %Keeps track of the index in array ( Starts at 1 for Matlab )
    index = 1;
    
    %Data will be stored here, each index represents a time interval
    dataToExport = zeros(1, ceil(nFrames / numFramesPerInterval));

    % Detection and Vehicle count for every frame in the video
    while hasFrame(videoObj.reader)
        % Stores a single frame of the video
        currFrame = readFrame(videoObj.reader);
        % Performs image filtering and blob analysis, then stores the centroids,
        % bboxes and the filtered Image
        [centroids, bboxes, filteredImage] = detectObjects(currFrame);
        % Predicts the new location of deteced objects
        predictNewLocations();
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
        %Displays results
        displayTrackingResults();

        %Adds to interval data
        if intervalCounter == numFramesPerInterval
            dataToExport(index) = totalCars;
            index = index + 1;
            % Resets the car count
            totalCars = 0;
            oldFrame = 0;
            intervalCounter = 0;
        else
            intervalCounter = intervalCounter + 1;
        end
    end
    
    % Adds remaining cars to end of array
    dataToExport(index) = totalCars;
    
    
    %%%%%% EXPORT FINAL DATA %%%%%%%%%%%%%%%%%%
    
    writematrix(dataToExport, 'finalData.csv')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%% FUNCTION DEFINITIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Calibration function
    function calibrating(trnframes)
  
        for i=1 : trnframes
        
            singleFrame = readFrame(videoObj.reader);
            
            % Train model
            step(videoObj.detector, singleFrame);
            
            %Insert Text
            position = [10,10];
            box_color = 'black';
            calImage = insertText(singleFrame,position,'Calibrating...',...
                'FontSize',18,'BoxColor', box_color,'TextColor','white');
            
            % Output video with calibrating text in top left corner
            % imshow(calImage);
            
        end
    end

    % Initial function to setup environment
    function videoObj = setupSystem()
        % Constructor function that initializes a new object to analyze
    
        % Video Reader method
        file = fullfile('..', 'static', 'uploads', 'traffic-test.mp4');
        videoObj.reader = VideoReader(file);

        % We are using 2 video player methods, one for the dislaying and one 
        % for the foreground detector
        videoObj.filteredPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
        videoObj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);

        % Now we need to just add the methods for the Foreground Detector and
        % Blob Analysis of the images
        videoObj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 150, 'MinimumBackgroundRatio', 0.7);

        videoObj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400);
    end

    % Function creates an empty array of structs with properties to track
    function trackArr = initializeTracks()
        % create an empty array of tracks
        trackArr = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end

    % Function performs image filtering and blob analysis
    function [centroids, bboxes, filteredImage] = detectObjects(currFrame)

        % Detect foreground.
        filteredImage = videoObj.detector.step(currFrame);

        % Apply morphological operations to remove noise and fill in holes.
        filteredImage = imopen(filteredImage, strel('rectangle', [3,3]));
        filteredImage = imclose(filteredImage, strel('rectangle', [15, 15]));
        filteredImage = imfill(filteredImage, 'holes');

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = videoObj.blobAnalyser.step(filteredImage);
    end

    % This function is responsible for predicting where the object will be of
    % it was covered by an external object (bridge, overpass, etc)
    function predictNewLocations()
        % By using the Kalman Filter (by MathWorks) we can predict the
        % location of each centroid in the given frame. We just need to update
        % the bbox around it to show that we have a idea as to where it is
        for i = 1:length(trackArr)
            bbox = trackArr(i).bbox;

            % Use the Kalman filter to track the object
            % We are assuming the velocity is constant so the prediction will
            % follow that given speed
            predictedCentroid = predict(trackArr(i).kalmanFilter);

            % Update the bounday box so that it follows the centroid
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            trackArr(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end

    % This function decides whether or not to use the predicted location
    % based on confidence of detection and minimized cost
    function [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment()

        nTracks = length(trackArr);
        nDetections = size(centroids, 1);

        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(trackArr(i).kalmanFilter, centroids);
        end

        % Solve the assignment problem using built in function.
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

    % This function updates and corrects the location estimation we make for
    % the tracks we detect
    % and updates the age of the tracks accordingly
    function updateAssignedTracks()
        % finds number of tracks to correct
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            % gets id of current track
            trackIdx = assignments(i, 1);
            % gets id of the detection for the track
            detectionIdx = assignments(i, 2);
            % gets the centroid from detection
            centroid = centroids(detectionIdx, :);
            % gets the box drawn for the detection
            bbox = bboxes(detectionIdx, :);

            % With the new centroid, corrects and updates the previous track
            correct(trackArr(trackIdx).kalmanFilter, centroid);

            % We can not replace the predicted bound box with the detected one
            trackArr(trackIdx).bbox = bbox;

            % The track gains age for each update
            trackArr(trackIdx).age = trackArr(trackIdx).age + 1;

            % The visibility of the track was updated so we update the count
            trackArr(trackIdx).totalVisibleCount = ...
                trackArr(trackIdx).totalVisibleCount + 1;
            % The invisible count must be set to 0 now that we have corrected
            % the prediction
            trackArr(trackIdx).consecutiveInvisibleCount = 0;
        end
    end

    % This function makes sure unassigned tracks are invisible
    function updateUnassignedTracks()
        % for each track in the unassigned tracks
        for i = 1:length(unassignedTracks)
            % get the unassigned track
            ind = unassignedTracks(i);
            % update the age of the unassigned track
            trackArr(ind).age = trackArr(ind).age + 1;
            % mark unassigned track as invisible
            trackArr(ind).consecutiveInvisibleCount = ...
                trackArr(ind).consecutiveInvisibleCount + 1;
        end
    end

    % Function deletes tracks that have been invisible for too many 
    % consecutive frames
    function deleteLostTracks()
        if isempty(trackArr)
            return;
        end

        invisibleForTooLong = 20;
        ageThreshold = 8;

        % Compute the fraction of the track's age for which it was visible.
        ages = [trackArr(:).age];
        totalVisibleCounts = [trackArr(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;

        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [trackArr(:).consecutiveInvisibleCount] >= invisibleForTooLong;

        % Delete lost tracks.
        trackArr = trackArr(~lostInds);
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
            trackArr(end + 1) = newTrack;

            % Increment the next id.
            nextId = nextId + 1;
        end
    end

    %This function draws a bounding box and label ID for each track ...
    % on the video frame and the foreground mask.
    %It then displays the frame and the mask in their respective video players
    function displayTrackingResults()
        % Convert the frame and the mask to uint8 RGB.
        currFrame = im2uint8(currFrame);
        filteredImage = uint8(repmat(filteredImage, [1, 1, 3])) .* 255;

        minVisibleCount = 8;
        if ~isempty(trackArr)

            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [trackArr(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = trackArr(reliableTrackInds);

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

                
                % A Stack ADT to update the total number of cars count
                currFrameNumCars = size(bboxes, 1);
      
                if currFrameNumCars >= oldFrame
                    totalCars = totalCars + (currFrameNumCars - oldFrame);
                    oldFrame = currFrameNumCars;
                else
                    oldFrame = currFrameNumCars;
                end
                
                % Draw the objects on the frame.
                currFrame = insertObjectAnnotation(currFrame, 'rectangle', ...
                    bboxes, labels);
                
                % Display total cars counter
                currFrame = insertText(currFrame, [10 10], totalCars,...
                'BoxOpacity', 1, 'FontSize', 15);
            end
        end

        % Display the mask and the frame.
        % videoObj.filteredPlayer.step(filteredImage);
        % videoObj.videoPlayer.step(currFrame);
    end
end
