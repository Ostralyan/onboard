package main

import (
	"os"
	"os/exec"
)

type OperatingSystem interface {
	preOnboardingSteps()
	installGit()
	installAWS()
	installPackageManager()
	defaultInstall(dep Dependency)
}

type MacOS struct {
}

func (mac MacOS) defaultInstall(dep Dependency) {
	if !dep.isInstalled() {
		dep.install()
	}
}

func (macOS MacOS) installGit() {
	git := new(MacGitDependency)
	macOS.defaultInstall(git)
}

func (macOS MacOS) installAWS() {
	aws := new(MacAWSCliDependency)
	macOS.defaultInstall(aws)
}

func (macOS MacOS) installPackageManager() {
	// /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

func (macOS MacOS) preOnboardingSteps() {
	println("Things that need to get done before installing")
}

type Dependency interface {
	isInstalled() bool
	install()
}

type MacAWSCliDependency struct {
}

type MacGitDependency struct {
}

func (git MacGitDependency) install() {

}

func (git MacGitDependency) isInstalled() bool {
	return false
}

func (aws MacAWSCliDependency) install() {
	println("installing awscli")
}

// needs brew
func (aws MacAWSCliDependency) isInstalled() bool {
	output, err := exec.Command("which", "aws").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}

	if string(output) == "" {
		exec.Command("brew", "install", "awscli").CombinedOutput()
		return false
	} else {
		println("AWS has already been installed")
		return true
	}
}

func main() {
	var myOS OperatingSystem
	var myTempOs string
	if myTempOs == "MacOS" {
		myOS = new(MacOS)
	}

	myOS.installGit()
	myOS.installAWS()
}
