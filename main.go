package main

import (
	"onboard/myos"
)

func main() {
	var myOS myos.OperatingSystem
	myOS = new(myos.MacOS)

	myOS.InstallPackageManager()
	myOS.InstallGit()
	myOS.InstallAWS()
}
