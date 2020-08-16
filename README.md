# Smart-Traffic-Control-System

Created By: Patrik Beqo, Sathira Katugaha and Sarvath Sharma

Link to Web App: https://traffic.xor.dev/

# Purpose:
We are on the verge of creating a Smart Traffic Control System. By using Image Processing Tools from Matlab we aim to take an input, which will be a video of an intersection where we will interpret the density of the traffic flow throughout certain points in time. This data will then be used to determine the duration of traffic signals and will show a histogram of the traffic flow. The histogram will show the number of cars and from which direction the density is the largest (TBD). 

# Process:
1. Grab videos of traffic intersections
2. Analyze the density and patterns of the environment using Matlab
    1. Need to clean image and isolate vehicles on the road using foreground detection
    2. Once cleaned, use Blob Analysis/Kalman Filter to detect and track vehicles 
3. Using a Queue ADT, store the values of the traffic density into a CSV file
4. Using Python run the MATLAB script and display the graph of the traffic flow on the website
5. Using a server and host run the entire program instead of locally running it


# Video Format
We will be using .mp4 file format with 60fps video quality.
