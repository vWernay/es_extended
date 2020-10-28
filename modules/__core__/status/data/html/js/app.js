$(function() {

  let status = [];
    //{
    //  color: '#2ecc71',
    //  value: 0.30
    //},
    //{
    //  color: '#2980b9',
    //  value: 0.90
    //},
  //];



   const renderStatusElement = () => {
    $('#container').html('')
  
    for (let i = 0; i < status.length; i++) {
      $('#container').append('<div id="circle"></div>')

      var progressBar = 
        new ProgressBar.Circle('#circle', {
          color: status[i].color,
          strokeWidth: 15,
          duration: 2000, // milliseconds
          easing: 'easeInOut',
          trailColor: '#ddd',
          trailWidth: 15,
        });

        progressBar.animate(status[i].value); // percent
    }
  }
  
  //renderStatusElement()

  window.onData = function(data) {
    //if (data.update) {
      //status.length = 0;

      for (let i = 0; i < data.status.length; i++) {
        status.push(data.status[i]);
      }

      renderStatusElement()
    //}
  }

  window.onload = () => {
    window.addEventListener('message', event => {
      onData(event.data)
    })
  }

});