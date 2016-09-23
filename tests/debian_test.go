package tests

import (
	"io/ioutil"
	"os/exec"
	"strings"
	"testing"
)

// Run ls on the root directory to make sure the filesystem was created properly
func TestDebianIsUp(t *testing.T) {
	output, err := ioutil.ReadDir("/")
	if err != nil {
		t.Fatalf("Error running command: %s. Error: %s. Output %s.", "ls", err, output)
	}
}

func TestCanRunAptGet(t *testing.T) {
	path, err := exec.LookPath("apt-get")
	cmd := exec.Command(path, "help")
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Error running command: %s. Error: %s. Output %s.", "ls", err, output)
	}
}

func TestHasCorrectMirror(t *testing.T) {
	filename := "/etc/apt/sources.list"
	expected := `deb http://httpredir.debian.org/debian jessie main
deb http://httpredir.debian.org/debian jessie-updates main
deb http://security.debian.org jessie/updates main`
	actual, err := ioutil.ReadFile(filename)
	if err != nil {
		t.Fatalf("Failed to open %s. Error: %s", filename, err)
	}
	if strings.TrimSpace(expected) != strings.TrimSpace(string(actual[:])) {
		t.Fatalf("Sources.list is incorrect. List:\n %s Expected:\n %s", string(actual[:]), expected)
	}
}
