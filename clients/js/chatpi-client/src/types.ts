export enum BroadcastAction {
  NEW_MESSAGE = 'message:new',
  NEW_REACTION = 'reaction:new',
}

export type ChannelId = string;

export interface ChatpiPresence {
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
  typingTimeout: number;
}

export interface Message {
  text: string;
  files: Array<string>;
  replyTargetId: string;
}

export interface SendOptions {
  channelId: ChannelId;
  message: Message;
}

export enum ReactionClassifier {
  LAUGH = 'LAUGH',
  CRY = 'CRY',
  SMILE = 'SMILE',
  LOVE = 'LOVE',
  UNHAPPY = 'UNHAPPY',
}

export interface SendReactionOptions {
  channelId: ChannelId;
  reactionTargetId: string;
  classifier: ReactionClassifier;
}
