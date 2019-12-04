package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"math/rand"
	"strconv"
)

var loop, _ = strconv.Atoi(os.Getenv("LOOP"))
var array, _ = strconv.Atoi(os.Getenv("ARRAY"))

func handler(w http.ResponseWriter, r *http.Request) {
	checkpoint := os.Getenv("CHECKPOINT")
	fmt.Fprintf(w, "array=%d\nloop=%d\narray-init.go:v5\n checkpoint=%s\n", array, loop, checkpoint)
}

func main() {
	var num int64 = 0
	for j:=0; j < loop; j++{
		num = rand.Int63n(1000000)
	}
	rand.Seed(num)
	arr := make([]int64, array)
	for i:=0; i < array; i++{
		arr[i] = rand.Int63n(100)
	}

	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
