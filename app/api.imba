# import Iota from "@iota/iota.js/dist/iota.browser.min.js"



const client = new Iota.SingleNodeClient("http://chrysalis-nodes.iota.org/");
const INDEX = 'audio-dev-v4'

export def get-all-messages
	let messagesFromTangle = await client.messagesFind(Iota.Converter.utf8ToBytes(INDEX))
	# map every message to the promise of the fetch in parallel
	let promisesMessages = messagesFromTangle.messageIds.map do |messageId| get-message messageId
	let messages = await Promise.all promisesMessages

export def get-message messageId
	let message = await client.message(messageId)
	let data = Iota.Converter.hexToUtf8 message.payload.data
	let [title,track] = data.split('-')
	{ messageId, message: title, track }

# TODO Use binary to send data! I'm using text because of the heroku free server!
export def send-message message
	let messageJoin = message.message + '-' + message.track
	let tipsResponse = await client.tips!
	let submitMessage =
		parentMessageIds: tipsResponse.tipMessageIds.slice(0,Iota.MAX_NUMBER_PARENTS)
		payload:
			type: Iota.INDEXATION_PAYLOAD_TYPE
			index: Iota.Converter.utf8ToHex(INDEX)
			data: Iota.Converter.utf8ToHex(messageJoin)
	let messageId = await client.messageSubmit(submitMessage)