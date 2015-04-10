module.exports =
class AtomDictationView
  recognition = {}
  speaking = false
  listening = false

  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-dictation',  'overlay', 'from-top')
    atom.workspaceView.append(@element)

    # Create transcript elements
    @interimTranscriptElement = document.createElement('div')
    @interimTranscriptElement.id = 'interim'

    @finalTranscriptElement = document.createElement('div')
    @finalTranscriptElement.id = 'final'

    insertButton = document.createElement('button')
    insertButton.innerText = "Insert into document"
    insertButton.onclick = @insertText

    @element.appendChild(@finalTranscriptElement)
    @element.appendChild(@interimTranscriptElement)
    @element.appendChild(insertButton)

    recognition = new webkitSpeechRecognition()
    recognition.continuous = true
    recognition.interimResults = true

    #TODO: should be a setting
    recognition.lang = 'en-US'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  toggleListening: ->
    if not listening
      # Clear out the UI stuff
      @interimTranscriptElement.textContent = ""
      @finalTranscriptElement.textContent = ""

      if @element.hasAttribute 'hidden'
        @element.removeAttribute 'hidden'

      # Start listening to whatever is dictated
      recognition.onresult = @speechRecognitionResultsReceived
      recognition.start()

    else
      recognition.stop()

      # Hide the dictation UI now that we're done listening
      if @element.parentElement?
        @element.setAttribute('hidden', '');

    # toggle whether we're listening or not
    listening = not listening

  insertText: =>
    finalTranscriptText = document.getElementById('final').innerText
    if editor = atom.workspace.getActiveTextEditor()
      # insert whitespace at the end for now
      editor.insertText(finalTranscriptText + " ")

    # Clear out the final transcript when transferring the text from the
    # transcript to the editor
    @finalTranscriptElement.textContent = ""

  speechRecognitionResultsReceived: =>
    finalTranscript = ""
    interimTranscript = ""
    i = event.resultIndex

    while i < event.results.length
      if event.results[i].isFinal
        @finalTranscriptElement.innerText += event.results[i][0].transcript
      else
        interimTranscript += event.results[i][0].transcript
      ++i

    @finalTranscriptElement.textContent += finalTranscript
    @interimTranscriptElement.textContent = interimTranscript
