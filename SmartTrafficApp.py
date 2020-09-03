import csv
import os
import motionTracking
import matlab
import shutil
from os import path
from os.path import join
from flask import Flask, render_template, flash, request, redirect, url_for
from werkzeug.utils import secure_filename
import redis
from rq import Queue

ALLOWED_EXTENSIONS = {'mp4', 'MP4'}

app = Flask(__name__)
app.secret_key = 'oursecretkey'

r = redis.Redis()
q = Queue(connection=r)

APP_ROOT = path.dirname(path.abspath(__file__))
UPLOAD_FOLDER = join(APP_ROOT, 'static', 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

graphData = None
error = False
extensionError = False

def allowed_file(filename):
    extension = '.' in filename and filename.rsplit('.', 1)[1].lower()
    return '.' in filename and extension in ALLOWED_EXTENSIONS and extension


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


def get_data(response):
    global graphData
    global error
    global extensionError
    # In Linux server
    # if response and path.exists('/root/Smart-Traffic-Control-System/vehicleDetection/finalData.csv'):
    if response and path.exists('./vehicleDetection/finalData.csv'):
        # In linux server
        # with open('/root/Smart-Traffic-Control-System/vehicleDetection/finalData.csv', mode='r') as csv_file:
        with open('./vehicleDetection/finalData.csv', mode='r') as csv_file:
            # Grab Data
            data = list(csv.reader(csv_file))[0]
            numPlots = len(data)
            timeIntervals = []
            numCars = []
            for i in range(1, numPlots+1):
                timeIntervals.append(i * 10)
            for element in data:
                numCars.append(int(element))
            graphData = [timeIntervals, numCars]
            error = False
            extensionError = False
    else:
        graphData = None
        error = True
        extensionError = False


@app.route('/', methods=['GET', 'POST'])
@app.route('/home', methods=['GET', 'POST'])
def home():
    global extensionError
    global error
    global graphData
    if request.method == 'POST':
        print(request)
        print(request.files)
        if 'file' not in request.files:
            print('no file part')
            flash('No file part')
            return redirect(url_for('home'))
        file = request.files['file']
        if file.filename == '':
            print('no selected file')
            flash('No selected file')
            return redirect(url_for('home'))
        allowedExtension = allowed_file(file.filename)
        print("allowed extension " + allowedExtension if allowedExtension is not False else "")
        if file and allowedExtension is not False:
            print('creating file')
            savePath = join(UPLOAD_FOLDER, "traffic-test." + allowedExtension)
            file.save(savePath)
            job = q.enqueue(run_matlab)
            res = jobs.result
            get_data(res)
        else:
            extensionError = True
            error = False
            graphData = None
        return redirect(url_for('home'))

    # Opening csv file
    if request.method == 'GET':
        return render_template('index.html', data=graphData, error=error, extensionError=extensionError)


@app.route('/aboutus')
def aboutus():
    return render_template('aboutus.html')


if __name__ == '__main__':
    app.run(debug=True)
    # On linux server
    # app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)