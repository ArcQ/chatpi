/** @module chatpi-client */
import { Socket, Presence } from 'phoenixjs';

export const BROADCAST_ACTION = 'message:new';

/**
 * ## Chatpi Connection
 *
 *
 * Wrapped Channel Obj around a phoenix socket
 *
 * @typedef {Object} Connection~chatpi-client
 * @property {Channel} channel
 * @property {Array} presences
 */

export default class Connection {
  /**
   * creates a connection with channelIds
   * @param {Object} chanelConfig - Config object to connect to a specific channel
   * @param {string} chanelConfig.url - Url assigned for environment
   * @param {string} chanelConfig.apiKey - Apikey assigned to your application
   * @param {string} chanelConfig.channelIds - ChannelIds you would like to join
   * @param {string} chanelConfig.userToken - User token assigned
   * @param {string} chanelConfig.authorizationToken - Authorization token that includes id field
   * @param {string} chanelConfig.onPresenceChange - When state about one of your presences changes
   * @param {string} chanelConfig.onMessageReceive - When a messages is received in a channel
   * @return {Channel}
   * @example <caption>Join a channel</caption>
   * const connection = new Connection({
    url,
    apiKey,
    channelIds,
    userToken,
    authorizationToken,
    onPresenceChange });
  */
  constructor({
    url,
    apiKey,
    channelIds,
    userToken,
    authorizationToken,
    onPresencesChange,
    onMessageReceive,
  }) {
    console.info('--- Connecting to chatpi ---');

    this._apiKey = apiKey;

    this._socket = new Socket(`ws://${url}/socket`, {
      params: {
        userToken,
        token: authorizationToken,
      },
    });

    this._socket.connect();

    this.channels = channelIds.reduce(
      (prev, [channelId]) => ({
        ...prev,
        [channelId]: this._createChannel(channelId),
      }),
      {},
    );

    this.presences = {};
    this.onPresencesChange = onPresencesChange;
    this.onMessageReceive = onMessageReceive;
  }

  _createChannel(channelId) {
    const channel = this._socket.channel(
      `chat:${this.apiKey}:${channelId}`,
      {},
    );
    channel
      .join()
      .receive('ok', () => console.log('Connected to chatpi!'))
      .receive('error', ({ reason }) =>
        console.info(
          `Failed to join channel: ${channelId} with reason: `,
          reason,
        ),
      )
      .receive('timeout', () =>
        console.info(
          'Server response timed out: Networking issues or configuration not set up properly',
        ),
      );

    channel.on(BROADCAST_ACTION, msg => this.onMessageReceive(msg));

    channel.on('presence_state', state => {
      this.presences[channelId] = Presence.syncState(
        this.presences[channelId],
        state,
      );
      this.onPresencesChange(this.presences[channelId]);
    });

    channel.on('presence_diff', diff => {
      this.presences[channelId] = Presence.syncDiff(
        this.presences[channelId],
        diff,
      );
      this.onPresencesChange(this.presences[channelId]);
    });

    return channel;
  }

  /**
   * send a message
   * @param {Channel} channelId - Pass in the channel object created by createChannel
   * @param {string} chanelConfig.url - Url assigned for environment
   * @param {string} chanelConfig.userToken - User token assigned
   * @param {string} chanelConfig.authorizationToken - Authorization token that includes id field
   * @return {Channel}
   * @example <caption>Join a channel</caption>
   * sendMessage({ channel: 'cf4aeae1-cda7-41f3-adf7-9b2bb377be7d4', action, message })
        .then((response) => console.log(response));
   *
   */
  sendMessage = ({ channelId, action, message }) =>
    new Promise((resolve, reject) => {
      this.channels[channelId]
        .push(action, { text: message.text })
        .receive('ok', response => resolve({ response }))
        .receive('error', reasons => reject(new Error(reasons)))
        .receive('timeout', () =>
          console.info(
            'Send message timed out: Networking issues or configuration not set up properly',
          ),
        );
    });

  joinChannel(channelId) {
    this.channel[channelId] = createChannel(channelId);
  }

  leaveChannel(channelId) {
    delete this.channel[channelId];
  }

  watchPresence() {}

  removePresenceWatcher() {}

  getChannelById(channelId) {
    return this.channels[channelId];
  }

  getPresenceById(channelId) {
    return this.presences[channelId];
  }
}
