RecognizerView = require './recognizer-view'
StatusBarView = require './status-bar-view'
ErrorView = require './error-view'
{CompositeDisposable} = require 'atom'

WebSocketServer = require('websocket').server
http = require('http')

module.exports = Recognizer =
  recognizerView: null
  statusBarView: null
  errorView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    console.log('activated')

    @recognizerView = new RecognizerView(state.recognizerViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @recognizerView.getElement(), visible: false)

    @statusBarView = new StatusBarView(state.statusBarViewState)

    # @errorView = new ErrorView()
    # @errorPanel = atom.workspace.addModalPanel(item: @errorView.getElement(), visible: false)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'recognizer:toggle': => @toggle()

    @server = @createWebSocketServer()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @recognizerView.destroy()

    @server.close()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @statusBar.addRightTile(item: @statusBarView.getElement(), priority: 500)

  serialize: ->
    recognizerViewState: @recognizerView.serialize()
    statusBarViewState: @statusBarView.serialize()

  toggle: ->
    console.log 'Recognizer was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  createWebSocketServer: ->
    server = http.createServer (request, response) ->
      console.log((new Date()) + ' Received request for ' + request.url)
      response.writeHead(404)
      response.end()

    server.listen 4747, =>
      console.log((new Date()) + ' Server is listening on port 4747')
      @statusBarView.setStatus 'Server running'

    server.once 'error', (err) =>
      if err.code == 'EADDRINUSE'
        @statusBarView.setErrorStatus 'Port 4747 already in use'
        console.log('Recognizer (or port 4747) is already used somewhere else')

    wsServer = new WebSocketServer({
        httpServer: server,
        autoAcceptConnections: true # TODO: Should not use autoAcceptConnections for production applications
    })

    wsServer.on 'connect', (connection) =>
      console.log((new Date()) + ' Connection accepted.')
      @statusBarView.setStatus 'Client connected'

      connection.on 'message', (message) =>
        if message.type != 'utf8'
          console.log('Received message is not of utf-8 type:', message)
          return
        @recognizerView.updateMarkers(JSON.parse(message.utf8Data))

      connection.on 'close', (reasonCode, description) ->
        console.log((new Date()) + ' Peer ' + connection.remoteAddress + ' disconnected.')

    server
