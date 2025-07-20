package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", handlerFunc)
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Could not start HTTP server")
		return
	}
}

func handlerFunc(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid method, only GET supported.", http.StatusMethodNotAllowed)
		log.Print("This endpoint only accepts GET requests")
		return
	}

	if err := json.NewEncoder(w).Encode("Hello World!"); err != nil {
		http.Error(w, "Could not fetch a response", http.StatusBadRequest)
		log.Print("Could not fetch a response")
		return
	}
}
