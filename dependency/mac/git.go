package mac

import (
	"os"
	"os/exec"
)

type GitDependency struct{}

func (git GitDependency) Install() {
	println("Installing git via Xcode	")
	_, err := exec.Command("xcode-select", "--install").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
}

func (git GitDependency) IsInstalled() bool {
	output, err := exec.Command("which", "git").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}

	if string(output) == "" {
		return false
	} else {
		println("Git has already been installed")
		return true
	}
}
