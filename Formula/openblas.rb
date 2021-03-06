class Openblas < Formula
  desc "Optimized BLAS library"
  homepage "https://www.openblas.net/"
  url "https://github.com/xianyi/OpenBLAS/archive/v0.3.5.tar.gz"
  sha256 "0950c14bd77c90a6427e26210d6dab422271bc86f9fc69126725833ecdaa0e85"
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  bottle do
    cellar :any
    rebuild 1
    sha256 "90e460c6b700e414fbd27b03b2260e764307cdf920d457167c856b3e9cfc8c42" => :mojave
    sha256 "0a1dd348317d1043405e7f6de81c24defbab79e84cc342e3da25d3529232ab94" => :high_sierra
    sha256 "07d983a91beee164c8e6668a9105c5cb349a564e41addd3756e8356db88cde1f" => :sierra
    sha256 "ceec9319be57f68a227cd80ac6fb88d82bf22dd72a44898432eec77d086d4dd2" => :x86_64_linux
  end

  keg_only :provided_by_macos,
           "macOS provides BLAS and LAPACK in the Accelerate framework"

  depends_on "gcc" # for gfortran
  fails_with :clang

  def install
    ENV["DYNAMIC_ARCH"] = "1"
    ENV["USE_OPENMP"] = "1"

    # Must call in two steps
    system "make", "CC=#{ENV.cc}", "FC=gfortran", "libs", "netlib", "shared", *("NO_AVX512=1" unless OS.mac?)
    system "make", "PREFIX=#{prefix}", "install"

    so = OS.mac? ? "dylib" : "so"
    lib.install_symlink "libopenblas.#{so}" => "libblas.#{so}"
    lib.install_symlink "libopenblas.#{so}" => "liblapack.#{so}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <math.h>
      #include "cblas.h"

      int main(void) {
        int i;
        double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,
                    3, 3, 2, 1, A, 3, B, 3, 2, C, 3);
        for (i = 0; i < 9; i++)
          printf("%lf ", C[i]);
        printf("\\n");
        if (fabs(C[0]-11) > 1.e-5) abort();
        if (fabs(C[4]-21) > 1.e-5) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lopenblas",
                   "-o", "test"
    system "./test"
  end
end
