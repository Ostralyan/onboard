package mac

import (
	"os"
	"os/exec"
)

type AWSCliDependency struct{}

func (aws AWSCliDependency) Install() {
	println("Installing the AWS command line interface")
	_, err := exec.Command("brew", "install", "awscli").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
}

func (aws AWSCliDependency) IsInstalled() bool {
	output, err := exec.Command("which", "aws").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}

	if string(output) == "" {
		return false
	} else {
		println("AWS has already been installed")
		return true
	}
}
