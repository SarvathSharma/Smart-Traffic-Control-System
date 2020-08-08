var loadingAnimation = document.getElementById('loading-animation');
var graph = document.getElementById('graph');

document.getElementById('upload-form').addEventListener('submit', (e) => {
  loadingAnimation.style.display = 'block';
  graph.style.display = 'none';
});