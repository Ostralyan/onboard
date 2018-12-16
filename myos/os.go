package myos

type OperatingSystem interface {
	PreOnboardingSteps()
	InstallPackageManager()
	InstallGit()
	InstallAWS()
}
