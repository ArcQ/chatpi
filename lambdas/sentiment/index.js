const Sentiment = require("sentiment");
const sentiment = new Sentiment();

exports.handler = async function(event, context) {
  const { user = null, message = "", timestamp = +new Date() } = req.body;
  return sentiment.analyze(message).score;
};
