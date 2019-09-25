EXTRA_DIST=tclkit-darwin-univ-aqua \
           tclkit-linux-x86 tclkit-linux-x86_64 tclkit-win32.exe \
           tclkit-linux-armv7l Tclxml3.1-GenericPureTcl.zip
           

BUILT_SOURCES = tclkit${BEXEEXT}

noinst_SCRIPTS = tclkit${BEXEEXT}

EXTRA_SCRIPTS = tclkit-darwin-univ-aqua tclkit-linux-x86 tclkit-linux-x86_64 \
		 tclkit-win32.exe tclkit-linux-armv7l

tclkit${BEXEEXT}: $(TCLKITBSRC) $(top_builddir)/config.status
	cp $(srcdir)/$(TCLKITBSRC) ./tclkit${BEXEEXT}
	chmod +x ./tclkit${BEXEEXT}

FORCE:

