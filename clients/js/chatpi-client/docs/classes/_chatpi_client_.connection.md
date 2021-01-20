[@knotfive/chatpi-client-js](../README.md) › [Globals](../globals.md) › ["chatpi-client"](../modules/_chatpi_client_.md) › [Connection](_chatpi_client_.connection.md)

# Class: Connection

## Chatpi Connection

Wrapped Channel Obj around a phoenix socket

**`property`** {Channel} channel

**`property`** {Array} presences

## Hierarchy

* **Connection**

## Index

### Constructors

* [constructor](_chatpi_client_.connection.md#constructor)

### Properties

* [apiKey](_chatpi_client_.connection.md#private-apikey)
* [channels](_chatpi_client_.connection.md#private-channels)
* [onMessageReceive](_chatpi_client_.connection.md#private-onmessagereceive)
* [onPresenceChange](_chatpi_client_.connection.md#private-onpresencechange)
* [presences](_chatpi_client_.connection.md#private-presences)
* [socket](_chatpi_client_.connection.md#private-socket)
* [timeouts](_chatpi_client_.connection.md#private-timeouts)
* [typingTimeout](_chatpi_client_.connection.md#private-typingtimeout)

### Methods

* [createChannel](_chatpi_client_.connection.md#private-createchannel)
* [disconnect](_chatpi_client_.connection.md#disconnect)
* [getChannelById](_chatpi_client_.connection.md#getchannelbyid)
* [getPresenceById](_chatpi_client_.connection.md#getpresencebyid)
* [joinChannel](_chatpi_client_.connection.md#joinchannel)
* [leaveChannel](_chatpi_client_.connection.md#leavechannel)
* [removePresenceWatcher](_chatpi_client_.connection.md#removepresencewatcher)
* [sendMessage](_chatpi_client_.connection.md#sendmessage)
* [sendReaction](_chatpi_client_.connection.md#sendreaction)
* [startTyping](_chatpi_client_.connection.md#starttyping)
* [stopTyping](_chatpi_client_.connection.md#stoptyping)
* [watchPresence](_chatpi_client_.connection.md#watchpresence)

## Constructors

###  constructor

\+ **new Connection**(`config`: [ConnectionConfig](../interfaces/_types_.connectionconfig.md)): *[Connection](_chatpi_client_.connection.md)*

*Defined in [chatpi-client.ts:32](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L32)*

**`remarks`** creates a connection with channelIds, default typing timoute is 10 seconds

**`example`** <caption>Connect via apiKey</caption>
const connection = new Connection({
url,
apiKey,
channelIds,
userToken,
authorizationToken,
onPresenceChange,
typingTimeout,
// initial messages you want returned, before/after a message timestamp
//if you've never quered for messages before, just query before date.now
messageQuery,
});

**Parameters:**

Name | Type |
------ | ------ |
`config` | [ConnectionConfig](../interfaces/_types_.connectionconfig.md) |

**Returns:** *[Connection](_chatpi_client_.connection.md)*

## Properties

### `Private` apiKey

• **apiKey**: *string*

*Defined in [chatpi-client.ts:25](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L25)*

___

### `Private` channels

• **channels**: *Record‹[ChannelId](../modules/_types_.md#channelid), Channel›*

*Defined in [chatpi-client.ts:27](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L27)*

___

### `Private` onMessageReceive

• **onMessageReceive**: *[onMessageReceive](../interfaces/_types_.onmessagereceive.md)*

*Defined in [chatpi-client.ts:30](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L30)*

___

### `Private` onPresenceChange

• **onPresenceChange**: *[onPresenceChangeCb](../interfaces/_types_.onpresencechangecb.md)*

*Defined in [chatpi-client.ts:29](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L29)*

___

### `Private` presences

• **presences**: *Record‹[ChannelId](../modules/_types_.md#channelid), [ChatpiPresence](../interfaces/_types_.chatpipresence.md)›*

*Defined in [chatpi-client.ts:28](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L28)*

___

### `Private` socket

• **socket**: *Socket*

*Defined in [chatpi-client.ts:26](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L26)*

___

### `Private` timeouts

• **timeouts**: *object*

*Defined in [chatpi-client.ts:32](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L32)*

#### Type declaration:

___

### `Private` typingTimeout

• **typingTimeout**: *number* = 10000

*Defined in [chatpi-client.ts:31](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L31)*

## Methods

### `Private` createChannel

▸ **createChannel**(`channelId`: string): *Channel*

*Defined in [chatpi-client.ts:80](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L80)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | string |

**Returns:** *Channel*

___

###  disconnect

▸ **disconnect**(): *void*

*Defined in [chatpi-client.ts:219](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L219)*

**Returns:** *void*

___

###  getChannelById

▸ **getChannelById**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *Channel*

*Defined in [chatpi-client.ts:159](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L159)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *Channel*

___

###  getPresenceById

▸ **getPresenceById**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *[ChatpiPresence](../interfaces/_types_.chatpipresence.md)*

*Defined in [chatpi-client.ts:189](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L189)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *[ChatpiPresence](../interfaces/_types_.chatpipresence.md)*

___

###  joinChannel

▸ **joinChannel**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:163](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L163)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  leaveChannel

▸ **leaveChannel**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:167](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L167)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  removePresenceWatcher

▸ **removePresenceWatcher**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:212](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L212)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  sendMessage

▸ **sendMessage**(`__namedParameters`: object): *Promise‹string›*

*Defined in [chatpi-client.ts:112](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L112)*

send a message

**`example`** <caption>Join a channel</caption>
sendMessage({ channel: 'cf4aeae1-cda7-41f3-adf7-9b2bb377be7d4', message })
.then((response) => console.log(response));

**Parameters:**

▪ **__namedParameters**: *object*

Name | Type |
------ | ------ |
`channelId` | string |
`message` | [Message](../interfaces/_types_.message.md) |

**Returns:** *Promise‹string›*

___

###  sendReaction

▸ **sendReaction**(`__namedParameters`: object): *Promise‹string›*

*Defined in [chatpi-client.ts:138](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L138)*

send a reaction

**`example`** <caption>Join a channel</caption>
sendMessage({ channel: 'cf4aeae1-cda7-41f3-adf7-9b2bb377be7d4', message })
.then((response) => console.log(response));

**Parameters:**

▪ **__namedParameters**: *object*

Name | Type |
------ | ------ |
`channelId` | string |
`classifier` | [ReactionClassifier](../enums/_types_.reactionclassifier.md) |
`reactionTargetId` | string |

**Returns:** *Promise‹string›*

___

###  startTyping

▸ **startTyping**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:172](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L172)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  stopTyping

▸ **stopTyping**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:185](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L185)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  watchPresence

▸ **watchPresence**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:193](https://github.com/ArcQ/chatpi/blob/8af0fd6/clients/js/chatpi-client/src/chatpi-client.ts#L193)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*
