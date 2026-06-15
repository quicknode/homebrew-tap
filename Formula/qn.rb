class Qn < Formula
  desc "Command-line interface for the Quicknode SDK"
  homepage "https://www.quicknode.com/docs/welcome"
  version "0.1.10"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.1.10/quicknode-cli-aarch64-apple-darwin.tar.xz"
      sha256 "e7c290f90f4c5bd533016bf44e7bd19b1dac7e6e231e177fb7fea2a81c1af019"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.1.10/quicknode-cli-x86_64-apple-darwin.tar.xz"
      sha256 "11af1ef06928bf8f365801ed0e9928428a9e6abea41f754e5c7baf716806359a"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/quicknode/cli/releases/download/v0.1.10/quicknode-cli-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "a3f03b1124189c393aa0bacb01c8ef2a9927a8315d427004959b1e367ea3c167"
    end
    if Hardware::CPU.intel?
      url "https://github.com/quicknode/cli/releases/download/v0.1.10/quicknode-cli-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "69bcce71799f8f5810f1bff0f41196e0e1a1a0d5ad7a86520f9285f89b418021"
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
