package main

import (
	"fmt"
	"time"

	"github.com/shreynadiadwala/Person-Lyearn-Testing-Backend-Universe/packages/timeutil"
)

func GetCurrentTime() time.Time {
	return timeutil.GetCurrentTime()
}

func main() {
	fmt.Print("this is dummy consumer")
}
