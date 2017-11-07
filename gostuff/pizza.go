package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"
)

const (
	prefix = "https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/"
)

var (
	htclient = &http.Client{Timeout: 10 * time.Second}
)

func getJson(path string, target interface{}) error {
	println("DEBUG: Loading " + prefix + path)
	r, err := htclient.Get(prefix + path)
	if err != nil {
		return err
	}
	defer r.Body.Close()
	return json.NewDecoder(r.Body).Decode(target)
}

func main() {
	shopData := jsonGetBranches{}
	if err := getJson("get-branches", &shopData); err != nil {
		log.Fatal(err)
	}
	shopId := shopData.id()

	categoryData := jsonGetCategories{}
	if err := getJson("get-categories/"+strconv.Itoa(shopId), &categoryData); err != nil {
		log.Fatal(err)
	}

	for _, category := range categoryData.categories() {
		println(category.Name)

	}
}
