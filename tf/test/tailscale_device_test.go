package test

import (
	"context"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/hetznercloud/hcloud-go/v2/hcloud"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	tsclient "github.com/tailscale/tailscale-client-go/v2"
	"net"
	"os"
	"slices"
	"testing"
	"time"
)

// TestTailscaleDevice checks the following conditions
//   - no SSH connections possible using public IP
//   - SSH connection possible using internal IP
//   - auth key is returned
//   - device with the correct hostname is created in
//     the tailscale backend
func TestTailscaleDevice(t *testing.T) {
	var (
		hostname = "test-hostname"
		ctx      = context.Background()
	)

	token := os.Getenv("HCLOUD_TOKEN")

	hcClient := hcloud.NewClient(hcloud.WithToken(token))
	tsclient := &tsclient.Client{
		Tailnet: os.Getenv("TAILSCALE_TAILNET"),
		APIKey:  os.Getenv("TAILSCALE_API_KEY"),
	}

	key, _, err := hcClient.SSHKey.Get(ctx, "yannic-mac-work")
	require.NoError(t, err, "ssh key")

	res, _, err := hcClient.Server.Create(ctx, hcloud.ServerCreateOpts{
		Name: "tf-tailscale-device-test",
		ServerType: &hcloud.ServerType{
			Name: "cax11",
		},
		SSHKeys: []*hcloud.SSHKey{
			key,
		},
		Image: &hcloud.Image{
			Name: "ubuntu-24.04",
		},
	})
	require.NoError(t, err, "create server")

	data, err := os.ReadFile("/Users/yannic/.ssh/id_ed25519")
	require.NoError(t, err, "read ssh key")

	tfOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ModuleTailscaleDevice,
		Vars: map[string]any{
			"hostname":        hostname,
			"ssh_private_key": string(data),
			"address":         res.Server.PublicNet.IPv4.IP.String(),
		},
	})

	defer terraform.Destroy(t, tfOpts)

	terraform.InitAndApply(t, tfOpts)

	var (
		tsAddr    = terraform.Output(t, tfOpts, "tailscale_ipv4_address")
		tsAuthKey = terraform.Output(t, tfOpts, "tailscale_auth_key")
		host      = ssh.Host{
			Hostname:    tsAddr,
			SshUserName: "root",
			SshKeyPair: &ssh.KeyPair{
				PrivateKey: string(data),
			},
		}
	)

	assert.NotEmpty(t, tsAuthKey)

	WaitServerReady(t, tsAddr+":22", 1*time.Minute)

	ssh.CheckSshCommand(t, host, "echo '1'")

	host.Hostname = res.Server.PublicNet.IPv4.IP.String()
	_, err = ssh.CheckSshCommandE(t, host, "echo '1'")
	assert.Error(t, err)

	devices, err := tsclient.Devices().List(ctx)
	assert.NoError(t, err, "list tailscale devices")

	for _, d := range devices {
		if d.Hostname == hostname && slices.Contains(d.Addresses, tsAddr) {
			return
		}
	}
	t.Fatalf("could not find devices with hostname %s and address %s", hostname, tsAddr)
}

func WaitServerReady(t *testing.T, addr string, timeout time.Duration) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	for {
		conn, err := net.DialTimeout("tcp", addr, 1*time.Second)
		if err == nil {
			conn.Close()
			return
		}
		select {
		case <-ctx.Done():
			t.Fatalf("%s did not respond within %v", addr, timeout)
		case <-time.After(2 * time.Second):
			continue
		}
	}
}
