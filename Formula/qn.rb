class Qn < Formula
  desc "Command-line interface for the Quicknode SDK"
  homepage "https://www.quicknode.com/docs/welcome"
  version "0.2.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.2.0/quicknode-cli-aarch64-apple-darwin.tar.xz"
      sha256 "6db4fac4f6a7996e57f0e7aa6b8949058abe9fbe73eb94c9f4c1e1727a244ca9"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.2.0/quicknode-cli-x86_64-apple-darwin.tar.xz"
      sha256 "1976f75e80908062614a63a8ae2efcb97554810768d1f8cda903dce421c67601"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.2.0/quicknode-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "1d6b440ead6f88359888fa89ebd2dc470248a549cba72ea4a064fb508abb7775"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.2.0/quicknode-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "7b6ad50b427f0e8d3b9eab4b848e7e42b5948fd0b21824ebaac49cc2e18a069d"
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
