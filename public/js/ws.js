$(function() {
  

  var logger = jQuery(".log ul")
      Socket = window.MozWebSocket || window.WebSocket,
      protos = ['foo', 'bar', 'xmpp'],
      socket = new Socket('ws://' + location.hostname + ':' + location.port + '/ws', protos),
      index  = 0;
  var log = function(text) {
    logger.append('<li>' + text + '</li>');
  };
  socket.addEventListener('open', function() {
    // log('OPEN: ' + socket.protocol);
    // socket.send('Hello, world');
  });
  socket.onerror = function(event) {
    // log('ERROR: ' + event.message);
  };
  socket.onmessage = function(event) {
    console.log(event.data)
    var img = $("<img />").attr('src', 'image/' + event.data)
    .on('load', function() {
        if (!this.complete || typeof this.naturalWidth == "undefined" || this.naturalWidth == 0) {
            alert('broken image!');
        } else {
            $(".log").append(img);
        }
    });
    // log('MESSAGE: ' + event.data);
    // setTimeout(function() { socket.send(++index + ' ' + event.data) }, 2000);
  };
  socket.onclose = function(event) {
    // log('CLOSE: ' + event.code + ', ' + event.reason);
  };
// Handler for .ready() called.
});