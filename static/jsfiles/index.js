var loadingAnimation = document.getElementById('loading-animation');
var graph = document.getElementById('graph');
var helpText = document.getElementById('help-text');

document.getElementById('upload-form').addEventListener('submit', (e) => {
  loadingAnimation.style.display = 'block';
  graph.style.display = 'none';
  helpText.style.display = 'none';
});