class GccCrossM68kAT10 < Formula
  desc "GNU Compiler Collection 10.2.0 (Cross-compiler/m68k)"
  homepage "https://gcc.gnu.org"
  url "http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz"
  sha256 "27e879dccc639cd7b0cc08ed575c1669492579529b53c9ff27b0b96265fa867d"

  depends_on "binutils-cross-m68k"
  
  # All of these are probably not needed but #3 was a case where it wouldn't
  # build without them (maybe no previous install of platform GCC)
  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  
  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run so pretend we have an outdated makeinfo
    # to prevent their build.
    ENV["gcc_cv_prog_makeinfo_modern"] = "no"
    
    args = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--target=m68k-elf",
      "--enable-languages=c,c++",
      "--disable-nls",
      "--with-as=#{Formula["binutils-cross-m68k"].opt_bin}/m68k-elf-as",
      "--with-ld=#{Formula["binutils-cross-m68k"].opt_bin}/m68k-elf-ld",
      "--prefix=#{prefix}"
    ]
    
    mkdir "../build" do
      system "../gcc-#{version}/configure", *args
      system "make", "all-gcc", "all-target-libgcc"
      system "make", "install-gcc", "install-target-libgcc" 
      system "make", "all-target-libstdc++-v3"
      system "make", "install-target-libstdc++-v3"
    end
  end

  test do
    (testpath/"hello-c.c").write <<~EOS
      int main()
      {
        return 0;
      }
    EOS
    system "#{bin}/m68k-elf-gcc", "-ffreestanding", "-c", "-o", "hello-c.o", "hello-c.c"

    (testpath/"hello-cc.cc").write <<~EOS
      int main()
      {
        return 0;
      }
    EOS
    system "#{bin}/m68k-elf-g++", "-ffreestanding", "-c", "-o", "hello-cc.o", "hello-cc.cc"
  end
end
