package stringutil

import (
	"time"

	"github.com/shreynadiadwala/Person-Lyearn-Testing-Backend-Universe/packages/timeutil"
)

func GetCurrentTime() time.Time {
	return timeutil.GetCurrentTime()
}

func Reverse(s string) string {
	runes := []rune(s)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	return string(runes)

}
