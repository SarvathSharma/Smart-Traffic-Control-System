import os
import motionTracking
import matlab
import shutil


def run_matlab():
    # Get info on current directory and check files
    # Then move to the directory where the MATLAB script is
    currDir = os.getcwd()
    print("Current directory " + currDir)
    os.chdir("./vehicleDetection")
    # In the linux server
    # os.chdir('/root/Smart-Traffic-Control-System/vehicleDetection')
    projectDir = os.getcwd()
    print("Moved to " + projectDir)
    arr = os.listdir(projectDir)
    print("Initial files in directory " + str(arr))

    # Start the MATLAB engine and run the motionTracking script
    # After running the script show the new files in the directory
    # And shut down the MATLAB process to save hassle
    eng = motionTracking.initialize()
    try:
        eng.motionTracking(nargout=0)
    except:
        os.chdir("./../")
        return False
    arr2 = os.listdir(projectDir)
    print("Final files in directory " + str(arr2))
    eng.terminate()
    os.chdir("./../")
    # if path.exists('./static/videos/finalVideo.avi'):
    #     os.remove('static/videos/finalVideo.avi')
    #     shutil.move('vehicleDetection/finalVideo.avi', 'static/videos/')
    # else:
    #     shutil.move('vehicleDetection/finalVideo.avi', 'static/videos')
    return True