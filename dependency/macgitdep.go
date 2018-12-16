package dependency

import (
	"os"
	"os/exec"
)

type MacGitDependency struct {
}

func (git MacGitDependency) Install() {
	_, err := exec.Command("xcode-select", "--install").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
}

func (git MacGitDependency) IsInstalled() bool {
	output, err := exec.Command("which", "aws").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}

	if string(output) == "" {
		exec.Command("brew", "install", "awscli").CombinedOutput()
		return false
	} else {
		println("Git has already been installed")
		return true
	}
}
