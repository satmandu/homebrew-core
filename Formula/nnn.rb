class Nnn < Formula
  desc "Free, fast, friendly file browser"
  homepage "https://github.com/jarun/nnn"
  url "https://github.com/jarun/nnn/archive/v2.2.tar.gz"
  sha256 "88dd08d624ae7a61ef749b1e258e4b29ed61ba9fcc5a18813f291ce80efc5e74"
  head "https://github.com/jarun/nnn.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "f678ffcf42043c17dd4aaf4857d5d6cb738ae50e35485b81eca6382b2c1562a0" => :mojave
    sha256 "4337e0b9968a516f0518eb722f0757d34330d5967fec6a69840ce91b0592d6ac" => :high_sierra
    sha256 "f4d378f77db6f6b0cfaf65b530e6e0ed6cf39b58ce1924981ae60fc7f2d5f548" => :sierra
    sha256 "b12bd1090633adcf30432fccfcdee21af213e2461e8c36895b5d0fdfc37525d5" => :x86_64_linux
  end

  depends_on "readline"
  depends_on "ncurses" unless OS.mac?

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    # Test fails on CI: Input/output error @ io_fread - /dev/pts/0
    # Fixing it involves pty/ruby voodoo, which is not worth spending time on
    return if ENV["CIRCLECI"] || ENV["TRAVIS"]
    # Testing this curses app requires a pty
    require "pty"

    PTY.spawn(bin/"nnn") do |r, w, _pid|
      w.write "q"
      assert_match testpath.realpath.to_s, r.read
    end
  end
end
