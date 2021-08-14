import { PlayIcon, RecordIcon, StopIcon, ResetIcon, SendIcon } from './svg'

export tag PlayAudio
	
	def getTrack base64
		if base64
			let binary_string =  window.atob(base64)
			let lenx = binary_string.length
			let bytes = new Uint8Array( lenx )
			for i in [0 .. lenx]
				bytes[i] = binary_string.charCodeAt(i)

			let newAudioBlob = new Blob([bytes.buffer], { type: "audio/webm;codecs='opus'" })			
			return window.URL.createObjectURL(newAudioBlob)

	css self
		d:flex fld:column jc:center
		bg:teal2 @hover:teal3 color:teal8 m:10px bxs:lg
		p:2 fw:500 rd:16px ta:center pb@lt-xs:20px
	css figcaption tt:capitalize

	<self [o@suspended:0.4]>
		<div> "Listen to the: " 
			<a href=`https://explorer.iota.org/mainnet/message/{data.messageId}` target="_blank"> data.message
		<audio$audio [mt:2px] controls src=getTrack(data.track)>
			"Your browser does not support the audio element"

tag Timer
	prop duration = 2000 # 3 seconds
	prop step = 50

	elapsed = 0

	get elapsedTime do (elapsed / 1000).toFixed(1)
	get durationInSeconds do (duration/1000).toFixed(0)

	def runTimer
		#interval = setInterval(&, step) do
			elapsed = elapsed + step
			if elapsed >= duration 
				stopTimer!
				emit('timeout')
			imba.commit!

	def stopTimer
		#interval
		clearInterval(#interval)

	def resetTimer
		elapsed = 0
		clearInterval(#interval)

export tag AudioTimer < Timer

	prop message
	mediaRecorder
	userMediaAudio
	audioChunks = []
	
	def unmount do stopTimer!

	def startRecord
		await setMediaRecorder! unless mediaRecorder
		if mediaRecorder and mediaRecorder.state != 'recording'
			mediaRecorder.start!
			runTimer!
			$recordButton.classList.add 'recording'
			
	def stopRecord
		if mediaRecorder and mediaRecorder.state != 'inactive'
			stopTimer!
			mediaRecorder.stop!
			userMediaAudio.getAudioTracks!.forEach do |track| track.stop!
			mediaRecorder = null
			imba.commit!

	def resetAudio
		stopRecord!
		resetTimer!
		setTimeout(&,100) do
			audioChunks = []
			imba.commit!

	def upload
		unless message
			window.alert "Title is required!"
			$message.focus!
			return
		let arr = await audioChunks[0].arrayBuffer!
		let trackBase64 = window.btoa(String.fromCharCode(...new Uint8Array(arr)))
		emit('sendToTangle',{ message , track: trackBase64 })
		$message.value = ''
		resetAudio!

	def setMediaRecorder
		userMediaAudio = await window.navigator.mediaDevices.getUserMedia({ audio: true })
		mediaRecorder = new MediaRecorder(userMediaAudio)
		mediaRecorder.addEventListener("dataavailable", &) do |event|
			audioChunks.push(event.data)
			if "srcObject" in $audio
				$audio.srcObject = userMediaAudio
			else 
				$audio.src = window.URL.createObjectURL(event.data)
			imba.commit!

	css section d:hflex cg:4 ai:center jc:center my:2
	css .message outline:none bg:red1 rd:16px bc:white p:1
	css footer d:hflex cg:2 ai:center jc:center
	css .hidden d:none
	css button
		rd:16px cursor:pointer
		&.send c@hover:red3
		&.recording animation: pulsate infinite 1.5s
	css progress
		w:8rem h:0.6rem rd:md
		&::-webkit-progress-bar bg:gray2 rd:md
		&::-webkit-progress-value bg:red4 rd:md
	
	<self @timeout=stopRecord! >
		
		<input$message bind=message placeholder='Title Audio...' autofocus=yes maxLength=30 minLength=3>

		<section>
			<progress value=(elapsed / duration)>
			"{elapsedTime}:{durationInSeconds}s"
		
		<footer>
			<audio$audio controls=no>
			
			<button title="Play" @click=$audio.play! .hidden=!audioChunks.length>
				<PlayIcon>

			<button$recordButton title="Record" @click=startRecord! .hidden=(audioChunks.length!=0)>
				<RecordIcon>

			<button title="Stop" @click=stopRecord!>
				<StopIcon>

			<button title="Reset" @click=resetAudio!>
				<ResetIcon>
			
			<button.send title="Send to Tangle" @click.flag-recording.throttle(2s)=upload! disabled=(audioChunks.length ==0)>
				<SendIcon>