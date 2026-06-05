class Qn < Formula
  desc "Command-line interface for the Quicknode SDK"
  homepage "https://www.quicknode.com/docs/welcome"
  version "0.1.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.1.3/quicknode-cli-aarch64-apple-darwin.tar.xz"
      sha256 "ab91cb081e9bffaabf1b2eb40e018cea961d9a8f64aad149020ed0e41be009f1"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.1.3/quicknode-cli-x86_64-apple-darwin.tar.xz"
      sha256 "d10f97136c561a50f1fe344651b03a72d87b49e4e37dc22af38bdd06f8321f33"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.1.3/quicknode-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "a1be4362a6344e838b38efe47def4b256804ccd3b304b4ac62a06b00a2ebea21"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.1.3/quicknode-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "d76e85cb9347e62032c18844e177ebc81d5f4640affb48f25c6728bd0871c7f3"
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

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
