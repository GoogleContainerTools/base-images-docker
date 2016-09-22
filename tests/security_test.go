package tests

import (
	"testing"
	"os/exec"
	"strings"
)

func TestPackageSecurity(t *testing.T) {
	path, err := exec.LookPath("apt-get")
	cmd := exec.Command(path, "-qq", "update")
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Error running command: %s. Error: %s. Output %s.", path, err, output)
	}

	cmd = exec.Command(path, "-qqs", "upgrade")
	output, err = cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("Error running command: %s. Error: %s. Output %s.", path, err, output)
	}
	if s := string(output[:]); strings.Contains(s, "Inst") && strings.Contains(s, "Security") {
		t.Fatalf("Security updates are required: %s", output)
	}
}
