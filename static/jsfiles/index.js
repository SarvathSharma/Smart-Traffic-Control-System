var loadingAnimation = document.getElementById('loading-animation');
var graph = document.getElementById('graph');
var routingLinks = document.getElementById('routing-links');

document.getElementById('select-button').addEventListener('click', (e) => {
  routingLinks.style.pointerEvents = 'none';
  loadingAnimation.style.display = 'block';
  graph.style.display = 'none';
  setTimeout(() => { 
    alert("Hello"); 
  }, 2000);
  loadingAnimation.style.display = 'none';
  routingLinks.style.pointerEvents = 'block';
  graph.style.display = 'block';
});