if( document.getElementById('myChart') ){
    var ctx = document.getElementById('myChart').getContext('2d');
    var data = JSON.parse(document.getElementById('myChart').getAttribute('data'));
    const xAxis = data[0];
    const yAxis = data[1];
    var chart = new Chart(ctx, {
        // The type of chart we want to create
        type: 'bar',

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
    var helpText = document.getElementById('help-text');
    helpText.style.display = 'block';
}else{
    var helpText = document.getElementById('help-text');
    helpText.style.display = 'none';
}
