import csv
from flask import Flask, render_template, flash, request, redirect, url_for

app = Flask(__name__)
app.secret_key = 'oursecretkey'

def get_data(fileName):
    # In linux server
    # with open('/root/Smart-Traffic-Control-System/vehicleDetection/{fileName}'.format(fileName = fileName), mode='r') as csv_file:
    with open('./vehicleDetection/{fileName}'.format(fileName = fileName), mode='r') as csv_file:
        # Grab Data
        data = list(csv.reader(csv_file))[0]
        numPlots = len(data)
        timeIntervals = []
        numCars = []
        for i in range(1, numPlots+1):
            timeIntervals.append(i * 10)
        for element in data:
            numCars.append(int(element))
        return [timeIntervals, numCars]


@app.route('/', methods=['GET'])
@app.route('/home', methods=['GET'])
def home():
    # Get Data
    graphData = [[], [], []]
    graphData[0] = get_data('finalData1.csv')
    graphData[1] = get_data('finalData2.csv')
    graphData[2] = get_data('finalData3.csv')
    return render_template('index.html', data=graphData)


@app.route('/aboutus')
def aboutus():
    return render_template('aboutus.html')


if __name__ == '__main__':
    app.run(debug=True)
    # On linux server
    # app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)