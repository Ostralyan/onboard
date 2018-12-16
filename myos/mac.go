package myos

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
