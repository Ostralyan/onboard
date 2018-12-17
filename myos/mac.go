package myos

import (
	mac "onboard/dependency/mac"
	"onboard/util"
)

type MacOS struct {
}

func (macOS MacOS) InstallGit() {
	git := new(mac.GitDependency)
	util.DefaultInstall(git)
}

func (macOS MacOS) InstallAWS() {
	aws := new(mac.AWSCliDependency)
	util.DefaultInstall(aws)
}

func (macOS MacOS) InstallPackageManager() {
	pm := new(mac.PackageManagerDepdendency)
	util.DefaultInstall(pm)
}

func (macOS MacOS) InstallNginx() {
	nginx := new(mac.NginxDependency)
	util.DefaultInstall(nginx)
}

func (macOS MacOS) PreOnboardingSteps() {
	println("Things that need to get done before installing")
	println("Install docker")
	println("Get ssh keys")
	println("Have aws credentials")
}
