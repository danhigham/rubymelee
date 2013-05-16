var http = require('http'),
    faye = require('faye');

var bayeux = new faye.NodeAdapter({mount: '/melee', timeout: 45});

bayeux.bind('publish', function (client_id, channel, data){
  console.log("#########################");
  console.log("Publish to :- " + channel + " : " + data);
});

bayeux.bind('handshake', function (client_id){
  console.log("#########################");
  console.log("Connect from :- " + client_id);
});

bayeux.listen(8000);