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

### Methods

* [createChannel](_chatpi_client_.connection.md#private-createchannel)
* [disconnect](_chatpi_client_.connection.md#disconnect)
* [getChannelById](_chatpi_client_.connection.md#getchannelbyid)
* [getPresenceById](_chatpi_client_.connection.md#getpresencebyid)
* [joinChannel](_chatpi_client_.connection.md#joinchannel)
* [leaveChannel](_chatpi_client_.connection.md#leavechannel)
* [removePresenceWatcher](_chatpi_client_.connection.md#removepresencewatcher)
* [sendMessage](_chatpi_client_.connection.md#sendmessage)
* [watchPresence](_chatpi_client_.connection.md#watchpresence)

## Constructors

###  constructor

\+ **new Connection**(`config`: [ConnectionConfig](../interfaces/_types_.connectionconfig.md)): *[Connection](_chatpi_client_.connection.md)*

*Defined in [chatpi-client.ts:29](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L29)*

**`remarks`** creates a connection with channelIds

**`example`** <caption>Connect via apiKey</caption>
const connection = new Connection({
url,
apiKey,
channelIds,
userToken,
authorizationToken,
onPresenceChange });

**Parameters:**

Name | Type |
------ | ------ |
`config` | [ConnectionConfig](../interfaces/_types_.connectionconfig.md) |

**Returns:** *[Connection](_chatpi_client_.connection.md)*

## Properties

### `Private` apiKey

• **apiKey**: *string*

*Defined in [chatpi-client.ts:24](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L24)*

___

### `Private` channels

• **channels**: *Record‹[ChannelId](../modules/_types_.md#channelid), Channel›*

*Defined in [chatpi-client.ts:26](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L26)*

___

### `Private` onMessageReceive

• **onMessageReceive**: *[onMessageReceive](../interfaces/_types_.onmessagereceive.md)*

*Defined in [chatpi-client.ts:29](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L29)*

___

### `Private` onPresenceChange

• **onPresenceChange**: *[onPresenceChangeCb](../interfaces/_types_.onpresencechangecb.md)*

*Defined in [chatpi-client.ts:28](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L28)*

___

### `Private` presences

• **presences**: *Record‹[ChannelId](../modules/_types_.md#channelid), [ChatpiPresence](../interfaces/_types_.chatpipresence.md)›*

*Defined in [chatpi-client.ts:27](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L27)*

___

### `Private` socket

• **socket**: *Socket*

*Defined in [chatpi-client.ts:25](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L25)*

## Methods

### `Private` createChannel

▸ **createChannel**(`channelId`: string): *Channel*

*Defined in [chatpi-client.ts:71](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L71)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | string |

**Returns:** *Channel*

___

###  disconnect

▸ **disconnect**(): *void*

*Defined in [chatpi-client.ts:160](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L160)*

**Returns:** *void*

___

###  getChannelById

▸ **getChannelById**(`channelId`: any): *Channel*

*Defined in [chatpi-client.ts:117](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L117)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | any |

**Returns:** *Channel*

___

###  getPresenceById

▸ **getPresenceById**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *[ChatpiPresence](../interfaces/_types_.chatpipresence.md)*

*Defined in [chatpi-client.ts:130](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L130)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *[ChatpiPresence](../interfaces/_types_.chatpipresence.md)*

___

###  joinChannel

▸ **joinChannel**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:121](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L121)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  leaveChannel

▸ **leaveChannel**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:125](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L125)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  removePresenceWatcher

▸ **removePresenceWatcher**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:153](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L153)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*

___

###  sendMessage

▸ **sendMessage**(`__namedParameters`: object): *Promise‹string›*

*Defined in [chatpi-client.ts:103](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L103)*

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

###  watchPresence

▸ **watchPresence**(`channelId`: [ChannelId](../modules/_types_.md#channelid)): *void*

*Defined in [chatpi-client.ts:134](https://github.com/ArcQ/chatpi/blob/1a5d498/clients/js/chatpi-client/src/chatpi-client.ts#L134)*

**Parameters:**

Name | Type |
------ | ------ |
`channelId` | [ChannelId](../modules/_types_.md#channelid) |

**Returns:** *void*
