let btn1 = document.getElementById('graph1-button');
let btn2 = document.getElementById('graph2-button');
let btn3 = document.getElementById('graph3-button');

let graph1 = document.getElementById('graph');
let graph2 = document.getElementById('graph');
let graph3 = document.getElementById('graph');


btn1.addEventListener('click', (e) => {
  graph2.style.display = 'none';
  graph3.style.display = 'none';
  graph1.style.display = 'block';
 
});

btn2.addEventListener('click', (e) => {
  graph3.style.display = 'none';
  graph1.style.display = 'none';
  graph2.style.display = 'block';

});

btn3.addEventListener('click', (e) => {
  graph1.style.display = 'none';
  graph2.style.display = 'none';
  graph3.style.display = 'block';

});
