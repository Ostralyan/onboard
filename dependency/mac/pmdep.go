package dependency

import (
	"os"
	"os/exec"
)

type PackageManagerDepdendency struct {
}

func (pm PackageManagerDepdendency) Install() {
	exec.Command("/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"").CombinedOutput()
}

func (pm PackageManagerDepdendency) IsInstalled() bool {
	output, err := exec.Command("which", "brew").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}

	if string(output) == "" {
		println("Installing package manager for MacOS: brew")
		return false
	} else {
		println("Brew has already been installed")
		return true
	}
}
