var loadingAnimation = document.getElementById('loading-animation');
var graph = document.getElementById('graph');
var helpText = document.getElementById('help-text');
var errorText = document.getElementById('error-text');

document.getElementById('upload-form').addEventListener('submit', (e) => {
  loadingAnimation.style.display = 'block';
  if(graph){
    graph.style.display = 'none';
  }
  if(helpText){
    helpText.style.display = 'none';
  }
  if(errorText){
    errorText.style.display = 'none';
  }
});