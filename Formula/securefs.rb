class MacfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_macfuse_installed? }

  def self.binary_macfuse_installed?
    File.exist?("/usr/local/include/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  env do
    ENV.append_path "PKG_CONFIG_PATH",
                    "/usr/local/lib/pkgconfig:#{HOMEBREW_PREFIX}/lib/pkgconfig:"\
                    "#{HOMEBREW_PREFIX}/opt/openssl@1.1/lib/pkgconfig"

    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/fuse"
    end
  end

   def message
    "macFUSE is required to build securefs. Please run `brew install --cask macfuse` first."
  end
end

class Securefs < Formula
  desc "Filesystem with transparent authenticated encryption"
  homepage "https://github.com/jonBoone/securefs"
  url "https://github.com/jonBoone/securefs.git",
      tag:      "0.11.1a",
      revision: "34b1eed5e0920e7ae4561a4503447bfb4dbe523f"
  license "MIT"
  head "https://github.com/jonBoone/securefs.git"

  depends_on "cmake" => :build

  on_macos do
    depends_on MacfuseRequirement
  end

  on_linux do
    depends_on "libfuse"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "#{bin}/securefs", "version" # The sandbox prevents a more thorough test
  end
end
