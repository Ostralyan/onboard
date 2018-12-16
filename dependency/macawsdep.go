package dependency

import (
	"os"
	"os/exec"
)

type MacAWSCliDependency struct {
}

func (aws MacAWSCliDependency) Install() {
	_, err := exec.Command("brew", "install", "awscli").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
}

func (aws MacAWSCliDependency) IsInstalled() bool {
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
