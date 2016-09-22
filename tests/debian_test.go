package tests

import (
	"testing"
	"io/ioutil"
	"os"
	"os/exec"
	"bufio"
)

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
	file, err := os.Open("/etc/apt/sources.list")
	if err != nil {
		t.Fatalf("Cannot open sources.list. Error: %s.", err)
	}
	defer file.Close()
	sources := [3]string{"deb http://httpredir.debian.org/debian jessie main", "deb http://httpredir.debian.org/debian jessie-updates main", "deb http://security.debian.org jessie/updates main"}
	scanner := bufio.NewScanner(file)
	i := 0
	for scanner.Scan() {
		if scanner.Text() != sources[i] {
			t.Fatalf("Sources.list is inaccurate. Line: %s. Expected: %s.", scanner.Text(), sources[i])
		}
		i++
	}
}
