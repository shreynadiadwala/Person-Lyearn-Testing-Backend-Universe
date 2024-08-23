package calculator

import (
	"fmt"

	"github.com/shreynadiadwala/Person-Lyearn-Testing-Backend-Universe/packages/mathutil"
)

func Calculate() {
	fmt.Println("Add: ", mathutil.Add(2, 3))
	fmt.Println("Multiply: ", mathutil.Multiply(2, 3))
}
