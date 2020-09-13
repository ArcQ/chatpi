export enum BroadcastAction {
  NEW_MESSAGE = 'message:new',
}

export type ChannelId = string;

export interface ChatpiPresence {
  isTyping: boolean;
}

export interface Message {
  isTyping: boolean;
}

export interface onPresenceChangeCb {
  (channelId: ChannelId, presences: ChatpiPresence): void;
}

export interface onMessageReceive {
  (channelId: ChannelId, messages: ChatpiPresence): void;
}

export interface ConnectionConfig {
  url: string;
  apiKey: string;
  channelIds: Array<ChannelId>;
  userToken: string;
  authorizationToken: string;
  onPresenceChange: onPresenceChangeCb;
  onMessageReceive: onMessageReceive;
}

export interface Message {
  text: string;
}

export interface SendOptions {
  channelId: ChannelId;
  action: BroadcastAction;
  message: Message;
}
