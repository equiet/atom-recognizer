{CompositeDisposable} = require 'atom'

module.exports =
class ErrorView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('recognizer')

    # Create message element
    message = document.createElement('div')
    message.textContent = 'Recognizer (or port 4747) is already being used somewhere else. Only 1 instance of Atom can be running.'
    message.classList.add('message')
    @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element