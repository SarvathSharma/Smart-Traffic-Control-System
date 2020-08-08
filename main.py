# This is a python script that allows us to integrate with the MATLAB system
# The main purpose is to grab and analyze the data from the MATLAB script

# All the libraries needed
import os.path
import re
import shutil
import sys
import matlab.engine

# Get info on current directory and check files
# Then move to the directory where the MATLAB script is
currDir = os.getcwd()
print("Current directory " + currDir)
os.chdir("./vehicleDetection")
projectDir = os.getcwd()
print("Moved to " + projectDir)
arr = os.listdir(projectDir)
print("Initial files in directory " + str(arr))

# Start the MATLAB engine and run the motionTracking script
# After running the script show the new files in the directory
eng = matlab.engine.start_matlab()
eng.motionTracking(nargout=0)
arr2 = os.listdir(projectDir)
print("Final files in directory " + str(arr2))

# Given the list of the new files check each one of them and find the csv file
for x in arr2:
    fileToMove = re.match(r".*\.csv", x)
    if fileToMove:
        # If the csv file is found, move it to the same directory as the Python script
        print("File found: " + x)
        newPath = shutil.move(x, currDir)
        print(x + " moved to " + currDir)
        sys.exit()
    else:
        # If it was not found let the user know, then if none match print an error
        print('File not matching regex key, moving to next one')

print('No CSV file was found, check MATLAB script for errors')
