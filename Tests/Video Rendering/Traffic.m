clc;	% Clear command window.
clear;	% Delete all variables.

trafficVid = VideoReader('TrafficTest.mp4'); % Reading in video
nframes = trafficVid.NumFrames; % Calculating how many frames are in the video

for k = 1 : nframes
    singleFrame = read(trafficVid, k);

    % Convert to grayscale to do morphological processing.
    I = rgb2gray(singleFrame);
    
    
end
