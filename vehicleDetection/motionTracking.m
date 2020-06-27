% Using Kalman Filter and Motion Based tracking to determine and track 
% vehicles

clc;	% Clear command window.
clear;	% Delete all variables.

% Initial function to setup environment 
function initialObj = setupEnvironment()
    % This function will initialize the video reader/player
    % Along with that it will track the objects in the frames
    
    initialObj.videoReader = VideoReader('TrafficTest2.mp4'); % Read the video
    
    % We are using 2 video players, one for the dislaying and one for the
    % foreground detector
    initialObj.videoPlayer = vision.VideoPlayer('Position', ...
                                                [80, 300, 550, 400]);
    initialObj.foregroundPlayer = vision.VideoPlayer('Position', ...
                                                [740, 400, 700, 400]);
                                            
    % Now we need to just add the object for the Foreground Detector and
    % Blob Analysis of the images
    initialObj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
    initialObj.blobAnalyser = vision.BlobAnalysis('AreaOutputPort', ...
        false, 'BoundingBoxOutputPort', true, 'CentroidOutputPort', ...
        false, 'MinimumBlobArea', 250, 'ExcludeBorderBlobs', true);
end

