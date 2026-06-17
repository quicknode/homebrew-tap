class Qn < Formula
  desc "Command-line interface for the Quicknode SDK"
  homepage "https://www.quicknode.com/docs/welcome"
  version "0.1.12"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.1.12/quicknode-cli-aarch64-apple-darwin.tar.xz"
      sha256 "7e7917e6457b705148581472fef50d2f5ba27086667380bc0ed85f79619f9c50"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.1.12/quicknode-cli-x86_64-apple-darwin.tar.xz"
      sha256 "472799735f40efad8bc79e2a69beb1a3dc14f5bf7768cfc610d3c222794bbf1b"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.1.12/quicknode-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "86fabd9b9c6ed9bd98f8b01415280d7913ec369f446eaf915004290507bf600f"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.1.12/quicknode-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "812ae898735e9cadea4eefd6b8a46914a58a8d5db320ee2c31c41eb70a7f5307"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "aarch64-unknown-linux-gnu": {},
    "aarch64-unknown-linux-musl-dynamic": {},
    "aarch64-unknown-linux-musl-static": {},
    "x86_64-apple-darwin": {},
    "x86_64-pc-windows-gnu": {},
    "x86_64-unknown-linux-gnu": {},
    "x86_64-unknown-linux-musl-dynamic": {},
    "x86_64-unknown-linux-musl-static": {}
  }

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "qn"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "qn"
    end
    if OS.linux? && Hardware::CPU.arm?
      bin.install "qn"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "qn"
    end

    install_binary_aliases!

    generate_completions_from_executable(bin/"qn", "completions")

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
