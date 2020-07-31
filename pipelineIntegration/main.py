# This is a python script that allows us to integrate with the MATLAB system
# The main purpose is to grab and analyze the data from the MATLAB script

import matlab.engine

eng = matlab.engine.start_matlab()

print 'Hello World'