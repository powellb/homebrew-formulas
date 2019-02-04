class EmacsOsx < Formula
    desc "GNU Emacs text editor"
    homepage "https://www.gnu.org/software/emacs/"
    url "https://ftp.gnu.org/gnu/emacs/emacs-26.1.tar.xz"
    mirror "https://ftpmirror.gnu.org/emacs/emacs-26.1.tar.xz"
    sha256 "1cf4fc240cd77c25309d15e18593789c8dbfba5c2b44d8f77c886542300fd32c"
    head "git://git.savannah.gnu.org/emacs.git", :branch => "emacs-26"

    depends_on "gnutls"
    depends_on "imagemagick@6"
    depends_on "libpng"
    depends_on "jpeg"
    depends_on "librsvg"

    head do
      depends_on "autoconf" => :build
      depends_on "gnu-sed" => :build
      depends_on "texinfo" => :build
      depends_on "pkg-config" => :build
	    depends_on "gmp" => :build
	    depends_on "jansson" => :build
    end

    def install
      args = %W[
	         --prefix=#{prefix}
           --with-ns
           --with-modules
           	]
      if build.head?
        ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"
        system "./autogen.sh"
      end

	    system "./configure", *args
	    system "make"
      system "make", "install"

      prefix.install "nextstep/Emacs.app"
      if (bin/"emacs").exist?
         (bin/"emacs").unlink
      end
	    (bin/"emacs").write <<~EOS
	      #!/bin/bash
	      exec #{prefix}/Emacs.app/Contents/MacOS/Emacs "$@"
	    EOS
      bin.install_symlink prefix/"Emacs.app/Contents/MacOS/bin/emacsclient" => "emacsclient"
      bin.install_symlink prefix/"Emacs.app/Contents/MacOS/bin/etags" => "etags"
    end

    def caveats
	    target_dir = File.expand_path("~/Applications")
	    s = <<-EOS
      Run the following script to link the app into ~/Applications.
      /usr/bin/osascript << EOF
      tell application "Finder"
          set macSrcPath to POSIX file "#{prefix/"Emacs.app"}" as text
          set macDestPath to POSIX file "#{target_dir}" as text
          make new alias file to file macSrcPath at folder macDestPath
      end tell
      EOF
      EOS
    end

    test do
	    assert_equal "4", shell_output("#{bin}/emacs --batch --eval=\"(print (+ 2 2))\"").strip
    end
end
