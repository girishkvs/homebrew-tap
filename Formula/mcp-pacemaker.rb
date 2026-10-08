class McpPacemaker < Formula
  desc "Local MCP process supervisor and transport bridge"
  homepage "https://github.com/girishkvs/mcp-pacemaker"
  url "https://registry.npmjs.org/mcp-pacemaker/-/mcp-pacemaker-2.0.2.tgz"
  sha256 "b4360d457d1371c2e4ef8afbc4dc253639f7a528756fc07a073d807b0d05e55a"
  license "MIT"

  depends_on "node@24"

  resource "dependency-lock" do
    url "https://raw.githubusercontent.com/girishkvs/mcp-pacemaker/a9fd5be23a50d4f3e3b787b678a8e85bdfb45fa2/package-lock.json"
    sha256 "62f92175cd124818678166381c0acd0376cb9dedb2278d39eb4e4033368e2500"
  end

  def install
    libexec.install Dir["*"]
    resource("dependency-lock").stage do
      libexec.install "package-lock.json"
    end
    cd libexec do
      args = std_npm_args(prefix: false)
      ENV.prepend_path "PATH", formula_opt_bin("node@24")
      system "npm", "--version"
      system "npm", "ci", "--omit=dev", *args
    end
    [["mcp-pacemaker", "cli.mjs"], ["mcp-bridge", "mcp-bridge.mjs"]].each do |command, script|
      target = libexec/"bin"/script
      target.chmod 0555
      (bin/command).write_env_script target, PATH: "#{formula_opt_bin("node@24")}:$PATH"
    end
  end

  def caveats
    <<~EOS
      This package installs mcp-pacemaker and mcp-bridge only.
      Run mcp-pacemaker init explicitly when you want host configuration and
      auto-start changed. This formula does not create a brew services job.

      Before permanent removal, review and run mcp-pacemaker uninstall while
      the command is available. It stops the product's bridge, removes its
      auto-start registration and restores managed host configuration.
      Do not use that teardown step for a routine package upgrade.
      User configuration under ~/.mcp-pacemaker is not package payload.
    EOS
  end

  test do
    require "json"

    state_dir = testpath/".mcp-pacemaker"
    state_dir.mkpath
    (state_dir/"servers.json").write JSON.generate(
      "packaging-test" => {
        "command" => (formula_opt_bin("node@24")/"node").to_s,
        "args"    => ["-e", "process.stdin.resume()"],
      },
    )

    client_dir = if OS.mac?
      testpath/"Library/Application Support/Code/User"
    else
      testpath/".config/Code/User"
    end
    client_dir.mkpath
    client_config = client_dir/"mcp.json"
    original = JSON.generate("servers" => {}, "packagingMarker" => "unchanged")
    client_config.write original

    output = shell_output("#{bin}/mcp-pacemaker plan --client vscode --port 18791")
    assert_match "packaging-test", output
    assert_match "http://127.0.0.1:18791/packaging-test/mcp", output
    assert_equal original, client_config.read
    assert_equal false, (client_dir/"mcp.json.bak").exist?
    assert_equal false, (state_dir/"state.json").exist?
  end
end
