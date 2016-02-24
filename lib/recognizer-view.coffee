{CompositeDisposable} = require 'atom'

module.exports =
class RecognizerView
  markers: []

  constructor: (serializedState) ->
    # Get active text editor
    @updateCurrentEditor()

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('recognizer')

    # Create message element
    message = document.createElement('div')
    message.textContent = "The Recognizer package is Alive! It's ALIVE!"
    message.classList.add('message')
    @element.appendChild(message)

    # Create gutter
    @updateGutter()

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.onDidStopChangingActivePaneItem (item) => @updateCurrentEditor()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @subscriptions.dispose()

  getElement: ->
    @element

  updateMarkers: (functions) ->
    @removeAllMarkers()

    # Show only markers belonging to a currently opened file
    currentFilename = @editor?.buffer?.file.path
    functions = functions.filter((f) -> currentFilename.indexOf(f.filename) != -1)

    for {filename, location, hitCount} in functions
      @addMarker(location, hitCount)

    console.log("updated #{functions.length} markers in file #{filename}")

  updateCurrentEditor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @updateGutter()

  updateGutter: ->
    try
      @gutter?.destroy()
    @gutter = @editor?.addGutter(name: 'recognizer', priority: 100)

  removeAllMarkers: ->
    marker.destroy() for marker in @markers
    @markers = []

  addMarker: (location, hitCount) ->
    marker = @editor.markBufferRange [[location.start.line - 1, 0], [location.start.line - 1, 0]]
    item = document.createElement 'span'
    item.textContent = hitCount
    @editor.decorateMarker marker, { type: 'gutter', gutterName: 'recognizer', item: item, class: 'recognizer' }
    @markers.push marker