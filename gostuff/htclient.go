package main

import (
	"encoding/json"
	"net/http"
	"sync"
	"time"
)

var (
	wg       sync.WaitGroup
	htclient = &http.Client{Timeout: 10 * time.Second}
)

func getJson(path string, target interface{}) error {
	nprintln("DEBUG: Loading " + prefix + path)
	r, err := htclient.Get(prefix + path)
	if err != nil {
		return err
	}
	defer r.Body.Close()
	return json.NewDecoder(r.Body).Decode(target)
}
