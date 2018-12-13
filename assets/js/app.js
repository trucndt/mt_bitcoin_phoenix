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

channel.on('new:tx', function (payload) { // listen to the 'shout' event
  var li = document.createElement("li"); // creaet new list item DOM element
  var receiver = payload.to;    // get name from payload or set default
  li.innerHTML = '<b>[Transaction]:</b><br> <font size="2">*From: ' + payload.from
    + '<br> *To: ' + receiver + '<br>*Amount: ' +  payload.amt + '</font>'; // set li contents
//  ul.appendChild(li);                    // append to list
    ul.insertBefore(li, ul.childNodes[0])
});

channel.on(':join', function (payload) { // listen to the 'shout' event
  var myPub = document.getElementById('myPub'); // creaet new list item DOM element
    myPub.innerHTML = payload.myPub;
});

channel.on(':metric', function (payload) { // listen to the 'shout' event
  var metric = document.getElementById('metric');
  metric.rows[1].cells[1].innerHTML = payload.user;
  metric.rows[2].cells[1].innerHTML = payload.miner;
  metric.rows[3].cells[1].innerHTML = payload.noBlocks;
  metric.rows[4].cells[1].innerHTML = payload.noTx;
  metric.rows[5].cells[1].innerHTML = payload.noTx / payload.noBlocks;
  metric.rows[6].cells[1].innerHTML = payload.txsec;
  metric.rows[7].cells[1].innerHTML = payload.blocksec;
});

channel.on(':updateTable', function (payload) { // listen to the 'shout' event
    for(var i = address.rows.length - 1; i > 0; i--)
    {
        address.deleteRow(i);
    }

  var value;
  Object.keys(payload).forEach(function(key) {
    if (key != "myPub")
    {
        value = payload[key];
        var row = address.insertRow(address.rows.length);
        var cell1 = row.insertCell(0);
        var cell2 = row.insertCell(1);
        if (key == payload.myPub)
         {
            cell1.innerHTML = '<b>' + key + '</b>';
            cell2.innerHTML = '<b>' + value + '</b>';
         }
         else
         {
            cell1.innerHTML = key;
            cell2.innerHTML = value;
         }
    }

  });

});


channel.on(':mining', function (payload) { // listen to the 'shout' event
  var li = document.createElement("li"); // creaet new list item DOM element
  var receiver = payload.to;    // get name from payload or set default
  li.innerHTML = '<b>' + payload.status + '</b><br>'; // set li contents
//  ul.appendChild(li);                    // append to list
    ul.insertBefore(li, ul.childNodes[0])
});

channel.join(); // join the channel.

var ul = document.getElementById('tx-list');        // list of messages.
var receiver = document.getElementById('receiver');          // name of message sender
var btc = document.getElementById('btc');            // message input field
var address = document.getElementById('address');



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