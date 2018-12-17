package mac

import (
	"os"
	"os/exec"
)

type NvmDependency struct{}

// remember to write the result to ~/.bashrc
func (nvm NvmDependency) Install() {
	_, err := exec.Command("brew", "install", "nvm").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
}

// Check that ~/.nvm exists
func (nvm NvmDependency) IsInstalled() bool {
	return true
}
