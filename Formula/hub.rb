class Hub < Formula
  desc "Add GitHub support to git on the command-line"
  homepage "https://hub.github.com/"
  url "https://github.com/github/hub/archive/v2.9.0.tar.gz"
  sha256 "48aa49cd6eb14a4ea243019323bb0b8b193fc8c3fbdcc3597f87cca11ae0394c"
  head "https://github.com/github/hub.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "7d9c176f0d0403de37e8163bcb70b124a33087d073a150f74cdb06f14d7a989b" => :mojave
    sha256 "bd033644c86186e01c9fe00f840dd01d5258c4ffca3522fb6115052f4022879a" => :high_sierra
    sha256 "f187d6811693f665d747c14f9aeaecab31d7243691c4070640eaa1ea58f6ef98" => :sierra
    sha256 "5a2a89c2566f65505d6ab8a5f6d67d38180b21d6a0d67cb5f412f9191b441378" => :x86_64_linux
  end

  depends_on "go" => :build
  unless OS.mac?
    depends_on "util-linux" => :build # for col
    depends_on "groff" => :build
    depends_on "ruby" => :build
  end

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/github/hub").install buildpath.children
    cd "src/github.com/github/hub" do
      system "make", "install", "prefix=#{prefix}"

      prefix.install_metafiles

      bash_completion.install "etc/hub.bash_completion.sh"
      zsh_completion.install "etc/hub.zsh_completion" => "_hub"
      fish_completion.install "etc/hub.fish_completion" => "hub.fish"
    end
  end

  test do
    system "git", "init"

    # Test environment has no git configuration, which prevents commiting
    system "git", "config", "user.email", "you@example.com"
    system "git", "config", "user.name", "Your Name"

    %w[haunted house].each { |f| touch testpath/f }
    system "git", "add", "haunted", "house"
    system "git", "commit", "-a", "-m", "Initial Commit"
    assert_equal "haunted\nhouse", shell_output("#{bin}/hub ls-files").strip
  end
end
