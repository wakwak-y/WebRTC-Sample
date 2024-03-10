package server

import (
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"sync"
)

type WebSocketServer struct {
	port             int
	upgrader         websocket.Upgrader
	connectedClients map[*websocket.Conn]struct{}
	mutex            sync.Mutex
}

func NewWebSocketServer(port int) *WebSocketServer {
	return &WebSocketServer{
		port:             port,
		connectedClients: make(map[*websocket.Conn]struct{}),
		upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool {
				return true
			},
		},
	}
}

func (s *WebSocketServer) Start() {
	http.HandleFunc("/", s.handleWebSocket)
	log.Printf("Signaling server started listening on port %d\n", s.port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", s.port), nil))
}

func (s *WebSocketServer) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := s.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Error upgrading to WebSocket:", err)
		return
	}

	s.mutex.Lock()
	s.connectedClients[conn] = struct{}{}
	s.mutex.Unlock()

	defer func() {
		s.mutex.Lock()
		delete(s.connectedClients, conn)
		s.mutex.Unlock()
		if err := conn.Close(); err != nil {
			log.Println("Error closing connection:", err)
		}
	}()

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsCloseError(err, websocket.CloseGoingAway) {
				log.Println("Client disconnected")
				return
			}
			log.Println("Error reading message:", err)
			return
		}
		s.broadcast(msg, conn)
	}
}

func (s *WebSocketServer) broadcast(message []byte, sender *websocket.Conn) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	for conn := range s.connectedClients {
		if conn != sender {
			err := conn.WriteMessage(websocket.BinaryMessage, message)
			if err != nil {
				log.Println("Error broadcasting message:", err)
			}
		}
	}
}
