package mac

import (
	"os"
	"os/exec"
)

type NginxDependency struct{}

func (nginx NginxDependency) Install() {
	_, err := exec.Command("brew", "install", "nginx").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
}

func (nginx NginxDependency) IsInstalled() bool {
	output, err := exec.Command("which", "nginx").CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}

	if string(output) == "" {
		return false
	} else {
		println("Nginx has already been installed")
		return true
	}

}
