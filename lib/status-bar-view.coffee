module.exports =
class StatusBarView
  constructor: (serializedState) ->
    @element = document.createElement('div')
    @element.classList.add('status-bar-recognizer', 'inline-block')

    # Create message element
    @message = document.createElement('span')
    @message.textContent = "It's ALIVE!"
    @message.classList.add('message')
    @element.appendChild(@message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  setStatus: (message, error) ->
    @message.classList.remove('is-red')
    @message.textContent = 'П ' + message

  setErrorStatus: (message) ->
    @message.classList.add('is-red')
    @message.textContent = 'П ' + message

