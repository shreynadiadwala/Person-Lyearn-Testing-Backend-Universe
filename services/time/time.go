package time

import (
	"fmt"

	"github.com/shreynadiadwala/Person-Lyearn-Testing-Backend-Universe/packages/timeutil"
)

func CurrentTime() {
	fmt.Print(timeutil.GetCurrentTime())
}
