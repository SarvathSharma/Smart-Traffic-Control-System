var loadingAnimation = document.getElementById('loading-animation');
var graph = document.getElementById('graph');
var helpText = document.getElementById('help-text');
var errorText = document.getElementById('error-text');
var extensionErrorText = document.getElementById('extension-error-text');
var routingLinks = document.getElementById('routing-links');

document.getElementById('upload-form').addEventListener('submit', (e) => {
  routingLinks.style.pointerEvents = 'none';
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
  if(extensionErrorText){
    extensionErrorText.style.display = 'none';
  }
});