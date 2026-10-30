class Qn < Formula
  desc "Command-line interface for the Quicknode SDK"
  homepage "https://www.quicknode.com/docs/welcome"
  version "0.7.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.7.0/quicknode-cli-aarch64-apple-darwin.tar.xz"
      sha256 "cdf82a0160d9b79d864817aa1d5b681ea1498b0db5c4edfa9062aaac6186292d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.7.0/quicknode-cli-x86_64-apple-darwin.tar.xz"
      sha256 "f9450a1e46a9bb9db0d5bf1bc1255872ba0e41fc3657faf3012bf7a613b4ebb7"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.7.0/quicknode-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "08fabbdfa2be5ef8def5aee0fd2aaed8b6442fef12213de3d44102ba7b81aa09"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.7.0/quicknode-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "16543dc2d9cd40a887695c39c4cd33d8d9ca31084fabba8c15a86a1e22d0b938"
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
