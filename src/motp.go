package main

import (
	"crypto/md5"
	"encoding/hex"
	"errors"
	"flag"
	"fmt"
	"os"
	"strconv"
	"time"
)

func printUsage() {
	usageStr := "\n" +
		"Usage: motp -s {secret} -p {pin}" +
		"\n\n" +
		"OTP parameters can be set via environment variables MOTP_SECRET and MOTP_PIN.\n" +
		"In this case there's no need to pass any arguments to the program.\n" +
		"\n"
	fmt.Println(usageStr)
}
func checkParams(secret, pin *string) bool {
	if nil == secret || "" == *secret || nil == pin || "" == *pin {
		return false
	} else {
		return true
	}
}
func getParams() (string, string, error) {
	secret := flag.String("s", "", "mOTP secret")
	pin := flag.String("p", "", "mOTP pin")
	helpFlag := flag.Bool("h", false, "print help")
	flag.Parse()
	if *helpFlag {
		return "", "", errors.New("")
	}
	if !checkParams(secret, pin) {
		*secret = os.Getenv("MOTP_SECRET")
		*pin = os.Getenv("MOTP_PIN")
		if !checkParams(secret, pin) {
			return "", "", errors.New("invalid input parameters")
		}
	}
	return *secret, *pin, nil
}

func generateOTP(secret, pin string) string {
	counter := time.Now().Unix() / 10
	input := md5.Sum([]byte(strconv.FormatInt(counter, 10) + secret + pin))
	digest := hex.EncodeToString(input[:])
	code := digest[:6]
	return code
}

func main() {
	secret, pin, err := getParams()
	if nil != err {
		printUsage()
		return
	}
	fmt.Println(generateOTP(secret, pin))
}
