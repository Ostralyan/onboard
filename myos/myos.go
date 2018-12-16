package myos

type OperatingSystem interface {
	preOnboardingSteps()
	installGit()
	installAWS()
	installPackageManager()
	defaultInstall(dep Dependency)
}
