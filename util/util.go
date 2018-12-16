package util

import "onboard/dependency"

func DefaultInstall(dep dependency.Dependency) {
	if !dep.IsInstalled() {
		dep.Install()
	}
}
