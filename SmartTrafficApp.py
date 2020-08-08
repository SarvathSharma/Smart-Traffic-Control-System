import csv
import os
import os.path
import re
import shutil
import sys
import matlab.engine
from flask import Flask, render_template, flash, request, redirect, url_for
from werkzeug.utils import secure_filename

UPLOAD_FOLDER = './vehicleDetection'
ALLOWED_EXTENSIONS = {'mp4', 'MP4'}

app = Flask(__name__)
app.secret_key = 'patrikbicho'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


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


@app.route('/', methods=['GET', 'POST'])
@app.route('/home', methods=['GET', 'POST'])
def home():
    graphData = None
    if request.method == 'POST':
        if 'file' not in request.files:
            flash('No file part')
        file = request.files['file']
        if file.filename == '':
            flash('No selected file')
        allowedExtension = allowed_file(file.filename)
        print("allowed extension " + allowedExtension if allowedExtension is not False else "")
        if file and allowedExtension is not False:
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], "traffic-test." + allowedExtension))
        else:
            # Remove the given CSV file and then run the MATLAB script to get the new data file
            os.remove('finalData.csv')
            run_matlab()
            return render_template('index.html', data=graphData)

    # Opening csv file
    if request.method == 'GET':
      with open('finalData.csv', mode='r') as csv_file:
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
          print(graphData)
    return render_template('index.html', data=graphData)


@app.route('/aboutus')
def aboutus():
    return render_template('aboutus.html')


if __name__ == '__main__':
    app.run(debug=True)
