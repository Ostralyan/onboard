package dependency

type Dependency interface {
	IsInstalled() bool
	Install()
}
