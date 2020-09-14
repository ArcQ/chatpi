import { SocketConnectOption, Channel, Socket, Presence } from 'phoenix';
import {
  ChannelId,
  ChatpiPresence,
  ConnectionConfig,
  onPresenceChangeCb,
  onMessageReceive,
  SendOptions,
  BroadcastAction,
} from './types';

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

export class Connection {
  private apiKey: string;
  private socket: Socket;
  private channels: Record<ChannelId, Channel>;
  private presences: Record<ChannelId, ChatpiPresence>;
  private onPresenceChange: onPresenceChangeCb;
  private onMessageReceive: onMessageReceive;

  /**
   * @remarks creates a connection with channelIds
   * @example <caption>Connect via apiKey</caption>
   * const connection = new Connection({
    url,
    apiKey,
    channelIds,
    userToken,
    authorizationToken,
    onPresenceChange });
  */
  constructor(config: ConnectionConfig) {
    console.info('--- Connecting to chatpi ---');

    this.apiKey = config.apiKey;

    const socketConnectOptions: Partial<SocketConnectOption> = {
      params: {
        userToken: config.userToken,
        token: config.authorizationToken,
      },
    };

    this.socket = new Socket(`ws://${config.url}/socket`, socketConnectOptions);

    this.socket.connect();

    this.channels = config.channelIds.reduce(
      (prev, channelId) => ({
        ...prev,
        [channelId]: this.createChannel(channelId),
      }),
      {},
    );

    this.presences = {};
    this.onPresenceChange = config.onPresenceChange;
    this.onMessageReceive = config.onMessageReceive;
  }

  private createChannel(channelId: string): Channel {
    const channel = this.socket.channel(`chat:${this.apiKey}:${channelId}`, {});

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

    channel.on(BroadcastAction.NEW_MESSAGE, msg =>
      this.onMessageReceive(channelId, msg),
    );

    return channel;
  }

  /**
   * send a message
   * @example <caption>Join a channel</caption>
   * sendMessage({ channel: 'cf4aeae1-cda7-41f3-adf7-9b2bb377be7d4', message })
        .then((response) => console.log(response));
   *
   */
  sendMessage({ channelId, message }: SendOptions): Promise<string> {
    return new Promise((resolve, reject) => {
      this.channels[channelId]
        .push(BroadcastAction.NEW_MESSAGE, { text: message.text })
        .receive('ok', () => resolve('ok'))
        .receive('error', reasons => reject(new Error(reasons)))
        .receive('timeout', () =>
          console.info(
            'Send message timed out: Networking issues or configuration not set up properly',
          ),
        );
    });
  }

  getChannelById(channelId: ChannelId): Channel {
    return this.channels[channelId];
  }

  joinChannel(channelId: ChannelId): void {
    this.channels[channelId] = this.createChannel(channelId);
  }

  leaveChannel(channelId: ChannelId): void {
    this.channels[channelId].leave();
    delete this.channels[channelId];
  }

  getPresenceById(channelId: ChannelId): ChatpiPresence {
    return this.presences[channelId];
  }

  watchPresence(channelId: ChannelId): void {
    const channel = this.getChannelById(channelId);
    channel.on('presence_state', state => {
      this.presences[channelId] = Presence.syncState(
        this.presences[channelId] || {},
        state,
      );
      this.onPresenceChange(channelId, this.presences[channelId]);
    });

    channel.on('presence_diff', diff => {
      this.presences[channelId] = Presence.syncDiff(
        this.presences[channelId],
        diff,
      );
      this.onPresenceChange(channelId, this.presences[channelId]);
    });
  }

  removePresenceWatcher(channelId: ChannelId): void {
    const channel = this.getChannelById(channelId);
    channel.on('presence_state', () => void 0);
    channel.on('presence_diff', () => void 0);
    delete this.presences[channelId];
  }

  disconnect(): void {
    Object.values(this.channels).forEach(channel => channel.leave());
    this.channels = {};
    this.presences = {};
    this.socket.disconnect();
  }
}
