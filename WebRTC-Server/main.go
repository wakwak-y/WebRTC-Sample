package main

import "WebRTC-Server/server"

func main() {
	ws := server.NewWebSocketServer(8080)
	ws.Start()
}
