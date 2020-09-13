[@knotfive/chatpi-client-js](README.md) › [Globals](globals.md)

# @knotfive/chatpi-client-js

# Javascript Client for ChatPi

For api docs: [Globals](docs/globals.md)

###Usage
Create a connection obj. And then push to a channel

`js
const connection = new Connection({
  url,
  apiKey,
  channelIds,
  userToken,
  authorizationToken,
  onPresenceChange,
})

sendMessage({
  channel: 'cf4aeae1-cda7-41f3-adf7-9b2bb377be7d4',
  message: {
    text: 'hi',
  },
}).then((response) => console.log(response))
`
