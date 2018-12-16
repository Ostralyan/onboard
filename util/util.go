package util

import (
	dep "onboard/dependency"
)

func DefaultInstall(dep dep.Dependency) {
	if !dep.IsInstalled() {
		dep.Install()
	}
}
