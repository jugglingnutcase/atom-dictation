{CompositeDisposable} = require 'atom'

module.exports =
class Speaker
  speaking = false
  currentUtterance = null

  constructor: (serializeState) ->

  speak: ->
    if not speaking
      if editor = atom.workspace.getActiveTextEditor()
        text = editor.getText()
        currentUtterance = new SpeechSynthesisUtterance(text)
        currentUtterance.on('')
        speechSynthesis.speak(currentUtterance);

      console.log "Speaking to you!"

    else
      if message
        message.cancel()
      console.log "Done speaking to you!"

    # Toggle the state
    speaking = !speaking

  speechFinished: ->
    speaking = false
