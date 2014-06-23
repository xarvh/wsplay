
import base64

def websocketHandshake(raw_request):

    request = dict([line.split(': ') for line in raw_request.split('\r\n')[1:] if line])

    key = base64.b64decode(request['Sec-WebSocket-Key'])
    response_key = base64.b64encode(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')

    response = '\r\n'.join([
        'HTTP/1.1 101 Switching Protocols',
        'Upgrade: websocket',
        'Connection: Upgrade',
        'Sec-WebSocket-Accept: ' + response_key,
        'Sec-WebSocket-Protocol: chat',
        ''
        ''
        ])

    return response








#-------------------

import socket

host = '127.0.1.1'
port = 5000
print host, port

listening = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
listening.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
listening.bind((host, port))
listening.listen(5)

log = open('log', 'wt')


while True:
    (sock, address) = listening.accept()

    data = sock.recv(1024)
    log.write(data)
    answer = websocketHandshake(data)
    if answer:
        sock.send(answer)
        while True:
            data = sock.recv(1024)
            log.write(data)
            sock.send(data)
    else:
        sock.close()

