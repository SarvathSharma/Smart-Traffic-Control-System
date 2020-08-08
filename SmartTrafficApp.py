from flask import Flask, render_template
import csv
app = Flask(__name__)

@app.route('/')
@app.route('/home')
def home():
    # Opening csv file
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