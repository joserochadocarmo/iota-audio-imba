import './style'
import { PlayAudio, AudioTimer } from './player'
import * as api from './api'

tag App
	prop audios = []
	prop audio

	def setup do load!

	def load
		audios = await api.getAllMessages!
		imba.commit!

	def sendToTangle e
		let ok = await api.sendMessage e.detail
		load! if ok

	css self d:flex fld:column pos:absolute inset:0 p:10px
	css a td:none
	css footer bg:gray2 p:3
	css .red
		bg:red3 color:red8 m:10px bxs:lg min-width:150px
		p:4 fw:500 rd:16px ta:center
	css .content 
		d:flex p:2 m:0 mb:10px
		
	<self @sendToTangle=sendToTangle >
		<div.content>
			<img src="https://logos-download.com/wp-content/uploads/2018/04/Miota_logo_black.svg" [w:75px pr:5px]>
			<h2> "Recording audio for the Tangle"
			
		<div [fs:xs ta:center mb:10px c:red8]>
			"This is a demo application! Remember that data written to a DLT can't be DELETED or CHANGED. Be careful, be kind. :)"
			
		<div[d:flex flw:wrap px:1  of:auto jc@lt-sm:center]> 
			for {message,track,messageId} in audios
				<PlayAudio data={message, track, messageId} >
			<div.red>
				<AudioTimer>
				
		<div[flex:1]>
		<footer>
			<span> "You have {audios.length} Audios"
				
imba.mount <App>