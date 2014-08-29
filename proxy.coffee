WebSocketServer = require('websocket').server
http = require 'http'
net = require 'net'


proxyListeningPort = 8080
clientProtocol = 'mud-telnet'
serverUri = '192.168.1.10'
serverPort = 4000


# Logger
timestamp = -> new Date().toISOString()
log = {}
for l in ['log', 'info', 'warn', 'error'] then log[l] = -> console[l] timestamp(), arguments...


# Put logic here to detect whether the specified origin is allowed.
originIsAllowed = (origin) ->
  return true


proxy = http.createServer (request, response) ->
  log.info "Received request for #{request.url}"
  response.writeHead 404
  response.end()


proxy.listen proxyListeningPort, ->
  log.info "Proxy listening on port #{proxyListeningPort}, forward to #{serverUri}:#{serverPort}"


new WebSocketServer(httpServer: proxy, autoAcceptConnections: false).on 'request', (request) ->

  # Make sure we only accept requests from an allowed origin
  unless originIsAllowed request.origin
    request.reject()
    log.warn "Rejected origin #{request.origin}"
    return

  # Client connects via a websocket
  client = request.accept clientProtocol, request.origin
  name = client.remoteAddress
  log.info "Accepted origin #{request.origin} as #{name}"

  # Server is connected via normal socket
  server = net.connect serverPort, serverUri, ->
    log.info "Proxying for #{name}"

    # Keep the closure
    do (client, server, name) ->

      server.on 'data', (buffer) ->
        data = buffer.toString()
        log.log "server -> #{name}: #{data}"
        client.sendUTF data

      client.on 'message', (message) ->
        data = message.utf8Data
        log.log "#{name} -> server: #{data}"
        server.write message.utf8Data

      server.on 'end', ->
        data = 'Server closed the connection'
        log.error "-> #{name}: #{data}"
        client.sendUTF data
        client.close()

      client.on 'close', (reasonCode, description) ->
        log.info "#{name} disconnected"
        server.end()
