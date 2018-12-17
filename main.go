package main

import (
	"onboard/myos"
	"os"
)

func main() {
	var myOS myos.OperatingSystem
	myOS = new(myos.MacOS)

	checkComputerLanguage()

	myOS.PreOnboardingSteps()

	// Install dependencies
	myOS.InstallPackageManager()
	myOS.InstallGit()
	myOS.InstallAWS()
	myOS.InstallNginx()

	installationComplete()
}

func checkComputerLanguage() {
	lang := os.Getenv("LANG")
	correctLang := "en_US.UTF-8"

	if lang != correctLang {
		println("Change your $LANG to be WANTED_LANG")
		println("Found $COMPUTER_LANG")
	}
}

func installationComplete() {
	println("\n\nInstall script completed! Go to https://local.honestbuildings.com:8443 to view the website!")
}

// if [ "$COMPUTER_LANG" != "$WANTED_LANG" ]; then
//     echo "Change your \$LANG to be $WANTED_LANG";
//     echo "Found $COMPUTER_LANG";
// fi
