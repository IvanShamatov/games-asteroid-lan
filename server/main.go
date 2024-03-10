package main

import (
	"fmt"
	"log"
	"net"
	"time"
)

const (
	Host = "0.0.0.0"
	Port = "15730"
)

func main() {
	conn, err := net.ListenPacket("udp", Host+":"+Port)
	if err != nil {
		log.Fatalln("Could not start a listener %s", err)
	}
	defer conn.Close()

	log.Printf("Started TCP server on %s:%s", Host, Port)

	for {
		buf := make([]byte, 1024)
		_, addr, err := conn.ReadFrom(buf)
		if err != nil {
			log.Println("Could not accept connections: %s:%s", err, addr)
		}
		log.Printf("Accepted connection from %s", addr)
		go response(conn, addr, buf)
	}
}

func response(udpServer net.PacketConn, addr net.Addr, buf []byte) {
	time := time.Now().Format(time.ANSIC)
	responseStr := fmt.Sprintf("time received: %v. Your message: %v!", time, string(buf))

	udpServer.WriteTo([]byte(responseStr), addr)
}
