##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun May 5 08:13:34 2019
#  Last Modified : <190925.1202>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#    Copyright (C) 2019  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
##############################################################################


ACLOCAL_AMFLAGS = -I m4

SUBDIRS = BuildScripts BuildData Scripts ExtraDoc
EXTRA_DIST = README.md Doxyfile.in bootstrap

clean-local:
	-rm -rf man html latex GenerateStripboard.pdf

#GenerateStripboardModules = Scripts/FritzingPartsBreadboardEditor.tcl \
#				Scripts/FritzingPartsSchematicEditor.tcl \
#				Scripts/FritzingPartsPCBEditor.tcl \
#				Scripts/FritzingPartsEditor.tcl

GenerateStripboardLib = $(wildcard $(srcdir)/Scripts/*.tcl)


bin_SCRIPTS = GenerateStripboard$(EXEEXT)
man_MANS = man1/GenerateStripboard.1
pkgdatadir = $(datadir)/$(PACKAGE)/Doc
pkgdata_DATA = GenerateStripboard.pdf

install-data-hook: $(top_builddir)/html/index.html
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	   if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	    f=`echo $$p | sed -e 's|^.*/||'`; \
	    echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/html/$$f'"; \
	    $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done

uninstall-hook:  
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	   if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	    f=`echo $$p | sed -e 's|^.*/||'`; \
	    echo " rm -f '$(DESTDIR)$(pkgdatadir)/html/$$f'"; \
	    rm -f "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}
BUILT_SOURCES = $(TCLKIT)

GenerateStripboard$(EXEEXT) : Scripts/GenerateStripboard.tcl \
	$(GenerateStripboardLib) ExtraDoc/Version.tcl COPYING
	-rm -rf GenerateStripboard.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/Scripts/GenerateStripboard.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap GenerateStripboard.kit
	-rm -rf GenerateStripboard.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit GenerateStripboard \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit GenerateStripboard \
		lib $(URILIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir)/Scripts GenerateStripboard \
		lib/Common $(GenerateStripboardLib) ExtraDoc/Version.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit GenerateStripboard \
		Common
	$(UNZIP) -qq -d GenerateStripboard.vfs/lib \
		$(top_srcdir)/BuildData/Tclxml3.1-GenericPureTcl.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit GenerateStripboard \
		License $(top_builddir)/COPYING
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap GenerateStripboard${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf GenerateStripboard.vfs GenerateStripboard.kit


$(top_builddir)/html/index.html \
	man1/GenerateStripboard.1 \
	GenerateStripboard.pdf : Doxyfile Scripts/GenerateStripboard.tcl \
		$(wildcard ExtraDoc/*.h) \
		ExtraDoc/Version.tcl BuildScripts/tcldoxyfilter.sh
	-rm -rf man1 html latex
	$(DOXYGEN)
	$(MAKE) -C latex
	mv latex/refman.pdf ./GenerateStripboard.pdf


Doxyfile: Doxyfile.in
	

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

ExtraDoc/Version.tcl: FORCE
	$(MAKE) -C $(top_builddir)/ExtraDoc Version.tcl

FORCE:

