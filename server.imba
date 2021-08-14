import express from 'express'
import index from './app/index.html'
import { SingleNodeClient, Converter,INDEXATION_PAYLOAD_TYPE,MAX_NUMBER_PARENTS } from "@iota/iota.js"

const app = express!
app.use express.json!
const client = new SingleNodeClient('https://chrysalis-nodes.iota.org')
const INDEX = 'audio-dev-v4'

app.get('/') do |req,res|
	unless req.accepts(['image/*', 'html']) == 'html'
		return res.sendStatus(404)
	res.send index.body

app.get('/get-all-messages') do |req,res|
	let messagesFromTangle = await client.messagesFind(Converter.utf8ToBytes(INDEX))
	# map every message to the promise of the fetch in parallel
	let promisesMessages = messagesFromTangle.messageIds.map do |messageId| get-message messageId
	let messages = await Promise.all promisesMessages 
	res.send messages

def get-message messageId
	let message = await client.message(messageId)
	let data = Converter.hexToUtf8 message.payload.data
	let [title,track] = data.split('-')
	{ messageId, message: title, track }

# TODO Use binary to send data! I'm using text because of the heroku free server!
app.post('/send-message') do |req,res|
	let message = req.body.message.message + '-' + req.body.message.track
	let tipsResponse = await client.tips!
	let submitMessage =
		parentMessageIds: tipsResponse.tipMessageIds.slice(0,MAX_NUMBER_PARENTS)
		payload:
			type: INDEXATION_PAYLOAD_TYPE
			index: Converter.utf8ToHex(INDEX)
			data: Converter.utf8ToHex(message)
	let messageId = await client.messageSubmit(submitMessage)
	res.send({result: messageId})

imba.serve app.listen(process.env.PORT or 3001)