// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

var channel = socket.channel('transaction:lobby', {}); // connect to chat "room"

channel.on('shout', function (payload) { // listen to the 'shout' event
  var li = document.createElement("li"); // creaet new list item DOM element
  var receiver = payload.receiver || 'guest';    // get name from payload or set default
  li.innerHTML = "Sending " + payload.btc + " BTC to "+ receiver; // set li contents
  ul.appendChild(li);                    // append to list

});

channel.join(); // join the channel.


var ul = document.getElementById('tx-list');        // list of messages.
var receiver = document.getElementById('receiver');          // name of message sender
var btc = document.getElementById('btc');            // message input field

// "listen" for the [Enter] keypress event to send a message:
receiver.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && btc.value.length > 0) { // don't sent empty msg.
    channel.push('shout', { // send the message to the server on "shout" channel
      receiver: receiver.value,     // get value of "name" of person sending the message
      btc: btc.value    // get message text (value) from msg input field.
    });
    receiver.value = '';
    btc.value = 0;         // reset the message input field for next message.
  }
});

btc.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && btc.value.length > 0) { // don't sent empty msg.
    channel.push('shout', { // send the message to the server on "shout" channel
      receiver: receiver.value,     // get value of "name" of person sending the message
      btc: btc.value    // get message text (value) from msg input field.
    });
    receiver.value = '';
    btc.value = 0;        // reset the message input field for next message.
  }
});