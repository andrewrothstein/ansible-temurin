package main

import (
	"fmt"
)

type Ver struct {
	Major int
	Minor int
	Patch int
	BVer string
}

func (v *Ver) Fmt() string {
	if v.Major >= 9 {
		return fmt.Sprintf("%d.%d.%d_%s", v.Major, v.Minor, v.Patch, v.BVer)
	} else {
		return fmt.Sprintf("%du%db%s", v.Major, v.Minor, v.BVer)
	}
}

func (v *Ver) lastRPath() string {
	if v.Major >= 9 {
		return fmt.Sprintf(
			"jdk-%d.%d.%d%%2B%s",
			v.Major, v.Minor, v.Patch, v.BVer,
		)
	} else {
		return fmt.Sprintf(
			"jdk%du%d-b%s",
			v.Major, v.Minor, v.BVer,
		)
	}
}

func (v *Ver) RPath() string {
	return fmt.Sprintf(
		"temurin%d-binaries/releases/downlad/%s",
		v.Major, v.lastRPath(),
	)
}

type Platform struct {
	Os string
	Arch string
	ArchiveType string
}

func NewPlatform(os string, arch string) Platform {
	return Platform{Os: os, Arch: arch, ArchiveType: "tar.gz"}
}

func (s *Platform) Fmt() string {
	return fmt.Sprintf("%s%s%s", s.Os, "_", s.Arch)
}

type Params struct {
	Mirror string
	Dir string
}

func dl_checksum(string checksum_url, string f) {
	
}

func dl_app(
	params *Params,
	app string,
	v *Ver,
	platforms []Platform,
) {
	fmt.Printf("      %s:\n", app)
	for _, p := range platforms {
		file := fmt.Sprintf(
			"OpenJDK%dU-%s_%s_hotspot_%s.%s",
			v.Major, app, p.Fmt(), v.Fmt(), p.ArchiveType,
		)
		rchecksumsurl := fmt.Sprintf(
			"%s/%s/%s.sha256.txt",
			params.Mirror, v.RPath(), file,
		)
		fmt.Printf("        # %s\n", rchecksumsurl)
		fmt.Printf("        %s: sha256:%s\n", p.Fmt(), "abcdef")
	}
}

func dlall(
	params *Params,
	v *Ver,
	platforms []Platform,
) {
	fmt.Printf("    '%s':\n", v.Fmt())
	dl_app(params, "jdk", v, platforms)
	dl_app(params, "jre", v, platforms)
}

func main() {
	params := Params{
		Mirror: "https://github.com/adoptium",
		Dir: "/home/arothste/Downloads",
	}
	v8 := Ver{Major: 8, Minor: 312, Patch: 0, BVer: "07"}
	v8Platforms := []Platform{
		NewPlatform("linux", "x64"),
		Platform{Os: "windows", Arch: "x64", ArchiveType: "zip"},
		Platform{Os: "windows", Arch: "x86-32", ArchiveType: "zip"},
		NewPlatform("linux", "aarch64"),
		NewPlatform("linux", "arm"),
		NewPlatform("linux", "ppc64le"),
		NewPlatform("mac", "x64"),
		NewPlatform("aix", "ppc64"),
	}
	dlall(&params, &v8, v8Platforms)

	v11 := Ver{Major: 11, Minor: 0, Patch: 13, BVer: "8"}
	v11Platforms := []Platform{
		NewPlatform("alpine-linux", "x64"),
		NewPlatform("linux", "s390x"),
		NewPlatform("linux", "x64"),
		Platform{Os: "windows", Arch: "x64", ArchiveType: "zip"},
		Platform{Os: "windows", Arch: "x86-32", ArchiveType: "zip"},
		NewPlatform("linux", "aarch64"),
		NewPlatform("linux", "arm"),
		NewPlatform("linux", "ppc64le"),
		NewPlatform("mac", "x64"),
		NewPlatform("aix", "ppc64"),
	}
	dlall(&params, &v11, v11Platforms)

	v17 := Ver{Major: 17, Minor: 0, Patch: 14, BVer: "9"}
	v17Platforms := []Platform{
		NewPlatform("alpine-linux", "x64"),
		NewPlatform("linux", "s390x"),
		NewPlatform("linux", "x64"),
		Platform{Os: "windows", Arch: "x64", ArchiveType: "zip"},
		Platform{Os: "windows", Arch: "x86-32", ArchiveType: "zip"},
		NewPlatform("linux", "aarch64"),
		NewPlatform("linux", "arm"),
		NewPlatform("linux", "ppc64le"),
		NewPlatform("mac", "x64"),
	}
	dlall(&params, &v17, v17Platforms)
}
