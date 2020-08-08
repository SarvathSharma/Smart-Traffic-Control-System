import csv
import os
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

@app.route('/', methods=['GET', 'POST'])
@app.route('/home', methods=['GET', 'POST'])
def home():
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