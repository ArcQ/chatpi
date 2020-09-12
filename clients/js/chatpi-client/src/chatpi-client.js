/** @module chatpi-client */
import { Socket } from 'phoenixjs';

export const BROADCAST_ACTION = 'message:new';

/**
 * ## Channel
 *
 * Channels are isolated, concurrent processes on the server that
 * subscribe to topics and broker events between the client and server.
 *
 * @typedef {Object} Channel~chatpi-client
 * @property {boolean} join(timeout)
 * @property {boolean} on(event, callback) - event can be any of 'ok'|'error'|'timeout'
 * @property {boolean} leave(callback)
 */

/**
 * creates a channel
 * @param {Object} chanelConfig - Config object to connect to a specific channel
 * @param {string} chanelConfig.url - Url assigned for environment
 * @param {string} chanelConfig.userToken - User token assigned
 * @param {string} chanelConfig.authorizationToken - Authorization token that includes id field
 * @return {Channel}
 * @example <caption>Join a channel</caption>
 * const channel = createChannel({ url, userToken, authorizationToken })
   channel
       .join()
       .receive('ok', ({ messages }) => console.log('catching up', messages))
       .receive('error', ({ reason }) => console.log('failed join', reason))
       .receive('timeout', () =>
         console.log('Networking issue. Still waiting...'),
       );
  channel.on(BROADCAST_ACTION, msg => console.log('Got message', msg));
 */
export const createChannel = async ({
  url,
  userToken,
  authorizationToken,
  channelId,
}) => {
  console.info('--- Connecting to chatpi ---');

  const socket = new Socket(`ws://${url}/socket`, {
    params: {
      userToken,
      token: authorizationToken,
    },
  });
  socket.connect();

  const channel = socket.channel(`chat:${channelId}`, {});

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

  return channel;
};

/**
 * send a message
 * @param {Channel} channel - Pass in the channel object created by createChannel
 * @param {string} chanelConfig.url - Url assigned for environment
 * @param {string} chanelConfig.userToken - User token assigned
 * @param {string} chanelConfig.authorizationToken - Authorization token that includes id field
 * @return {Channel}
 * @example <caption>Join a channel</caption>
 * const channel = createChannel({ url, userToken, authorizationToken })
   channel
       .join()
       .receive('ok', ({ messages }) => console.log('catching up', messages))
       .receive('error', ({ reason }) => console.log('failed join', reason))
       .receive('timeout', () =>
         console.log('Networking issue. Still waiting...'),
       );
  channel.on(BROADCAST_ACTION, msg => console.log('Got message', msg));
 * @example <caption>Example of push a message onto a socket</caption>
 * const action = BROADCAST_ACTION;
 * sendMessageAsync({ channel, action, message })
        .then((response) => console.log(response));
 *
 */
export const sendMessageAsync = ({ channel, action, message }) =>
  new Promise((resolve, reject) => {
    channel
      .push(action, { text: message.text })
      .receive('ok', response => resolve({ response }))
      .receive('error', reasons => reject({ reasons }))
      .receive('timeout', () =>
        console.info(
          'Send message timed out: Networking issues or configuration not set up properly',
        ),
      );
  });
