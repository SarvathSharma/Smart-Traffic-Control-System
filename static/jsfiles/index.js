var loadingAnimation = document.getElementById('loading-animation');
var graph = document.getElementById('graph');

document.getElementById('myform').addEventListener('submit', (e) => {
  loadingAnimation.style.display = 'block';
  graph.style.display = 'none';
});