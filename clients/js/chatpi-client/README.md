# Javascript Client for ChatPi

###Usage
Create a channel. And then push to that channel

`js
const channel = joinChannel({ url, userToken, authorizationToken });
channel
  .join()
  .receive('ok', ({ messages }) => console.log('catching up', messages))
  .receive('error', ({ reason }) => console.log('failed join', reason))
  .receive('timeout', () =>
    console.log('Networking issue. Still waiting...'),
  );
// listen to events
channel.on(BROADCAST_ACTION, msg => console.log('Got message', msg));

// push a message on to the channel
const action = BROADCAST_ACTION;
sendMessageAsync({ channel, action, message })
  .then((response) => console.log(response));
`
