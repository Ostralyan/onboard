package myos

import (
	"onboard/dependency"
	"onboard/util"
)

type MacOS struct {
}

func (macOS MacOS) InstallGit() {
	git := new(dependency.MacGitDependency)
	util.DefaultInstall(git)
}

func (macOS MacOS) InstallAWS() {
	aws := new(dependency.MacAWSCliDependency)
	util.DefaultInstall(aws)
}

func (macOS MacOS) InstallPackageManager() {

	pm := new(dependency.MacPackageManagerDepdendency)
	util.DefaultInstall(pm)
}

func (macOS MacOS) PreOnboardingSteps() {
	println("Things that need to get done before installing")
}
