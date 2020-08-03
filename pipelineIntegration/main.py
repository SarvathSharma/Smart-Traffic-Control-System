# This is a python script that allows us to integrate with the MATLAB system
# The main purpose is to grab and analyze the data from the MATLAB script

import sys
import matlab.engine
eng = matlab.engine.start_matlab()

positionOfPath = 1
sys.path.insert(positionOfPath, '../vehicleDetection/motionTracking.m')


# There are two ways we can do this. Either run it as a script or run it as a function

# Run it as a function

# Pass in inputs to the function
# ret = eng.MotionBasedMultiObjectTracking( *Need parameters here* )
# print(ret)
