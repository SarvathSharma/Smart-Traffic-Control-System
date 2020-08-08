import csv
import os
import os.path
import shutil
import sys
import matlab.engine
from os import path
from flask import Flask, render_template, flash, request, redirect, url_for
from werkzeug.utils import secure_filename

UPLOAD_FOLDER = './static/uploads'
ALLOWED_EXTENSIONS = {'mp4', 'MP4'}

app = Flask(__name__)
app.secret_key = 'oursecretkey'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

graphData = None

def allowed_file(filename):
    extension = '.' in filename and filename.rsplit('.', 1)[1].lower()
    return '.' in filename and extension in ALLOWED_EXTENSIONS and extension


def run_matlab():
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
    os.chdir("./../")

def get_data():
    if path.exists('./vehicleDetection/finalData.csv'):
        with open('./vehicleDetection/finalData.csv/', mode='r') as csv_file:
            # Grab Data
            data = list(csv.reader(csv_file))[0]
            numPlots = len(data)
            timeIntervals = []
            numCars = []
            for i in range(1, numPlots+1):
                timeIntervals.append(i * 10)
            for element in data:
                numCars.append(int(element))
            global graphData
            graphData = [timeIntervals, numCars]

@app.route('/', methods=['GET', 'POST'])
@app.route('/home', methods=['GET', 'POST'])
def home():
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
            file.save(path.join(app.config['UPLOAD_FOLDER'], "traffic-test." + allowedExtension))
            get_data()
            run_matlab()
            return redirect(url_for('home'))

    # Opening csv file
    if request.method == 'GET':
        return render_template('index.html', data=graphData)


@app.route('/aboutus')
def aboutus():
    return render_template('aboutus.html')


if __name__ == '__main__':
    app.run(debug=True)
