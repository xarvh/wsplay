
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

    while True:
        data = sock.recv(1024)
        log.write(data)
        sock.send(data)

