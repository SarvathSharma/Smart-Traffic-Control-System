clc;	% Clear command window.
clear;	% Delete all variables.
% Get the original image from the directory
original = imread('./Lines.jpg');
imshow(original);

% Convert it to grayscale (easier to process than colours)
grayScaled = rgb2gray(original);
imshow(grayScaled);

% Turn it into a binary image
binaryImage = imbinarize(grayScaled, ...
    'adaptive','ForegroundPolarity','dark');
binaryImage = ~binaryImage;
binaryImage = bwareaopen(binaryImage, 100);
sedisk = strel('disk', 2);
binaryImage = imclose(binaryImage, sedisk);
% binaryImage = imfill(binaryImage, 'holes');
% binaryImage = imclearborder(binaryImage);
imshow(binaryImage);

% Now we can make a boundary encasing the image and add a text to show the
% number of objects detected
% Hold on is used to retain the current plot while new ones are being
% generated
[B,L,N,A] = bwboundaries(binaryImage); 
figure;
imshow(original)
text(10,10,strcat('\color{green}Objects Found:',num2str(length(B))))
hold on; 
% Loop through object boundaries  
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 0.2)
end