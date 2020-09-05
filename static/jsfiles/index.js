let btn1 = document.getElementById('graph1-button');
let btn2 = document.getElementById('graph2-button');
let btn3 = document.getElementById('graph3-button');

let graph1 = document.getElementById('graph1');
let graph2 = document.getElementById('graph2');
let graph3 = document.getElementById('graph3');


btn1.addEventListener('click', () => {
  graph2.style.display = 'none';
  graph3.style.display = 'none';
  graph1.style.display = 'block';
 
});

btn2.addEventListener('click', () => {
  graph3.style.display = 'none';
  graph1.style.display = 'none';
  graph2.style.display = 'block';

});

btn3.addEventListener('click', () => {
  graph1.style.display = 'none';
  graph2.style.display = 'none';
  graph3.style.display = 'block';

});

//First Grpah Render
if( document.getElementById('myChart') ){
  let ctx = document.getElementById('myChart').getContext('2d');
  let data = JSON.parse(document.getElementById('myChart').getAttribute('data'));
  const xAxis = data[0];
  const yAxis = data[1];
  let chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',

      // The data for our dataset
      data: {
          labels: xAxis,
          datasets: [{
              label: 'Number of Cars vs Time (Seconds)',
              backgroundColor: 'rgb(255, 99, 132)',
              borderColor: 'rgb(255, 99, 132)',
              data: yAxis,
          }]
      },

      // Configuration options go here
      options: {}
  });
}

//Second Grpah Render
if( document.getElementById('myChart2') ){
  let ctx = document.getElementById('myChart2').getContext('2d');
  let data = JSON.parse(document.getElementById('myChart2').getAttribute('data'));
  const xAxis = data[0];
  const yAxis = data[1];
  let chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',

      // The data for our dataset
      data: {
          labels: xAxis,
          datasets: [{
              label: 'Number of Cars vs Time (Seconds)',
              backgroundColor: 'rgb(255, 99, 132)',
              borderColor: 'rgb(255, 99, 132)',
              data: yAxis,
          }]
      },

      // Configuration options go here
      options: {}
  });
}

//Third Grpah Render
if( document.getElementById('myChart3') ){
  let ctx = document.getElementById('myChart3').getContext('2d');
  let data = JSON.parse(document.getElementById('myChart3').getAttribute('data'));
  const xAxis = data[0];
  const yAxis = data[1];
  let chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',

      // The data for our dataset
      data: {
          labels: xAxis,
          datasets: [{
              label: 'Number of Cars vs Time (Seconds)',
              backgroundColor: 'rgb(255, 99, 132)',
              borderColor: 'rgb(255, 99, 132)',
              data: yAxis,
          }]
      },

      // Configuration options go here
      options: {}
  });
}