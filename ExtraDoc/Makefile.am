##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon May 6 01:13:58 2019
#  Last Modified : <190510.0840>
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


EXTRA_DIST=$(wildcard *.h)
CLEANFILES = Version.tcl

Version.tcl : $(top_builddir)/config.status
	echo '## @page Version Version' >Version.tcl
	echo "# Version is $(VERSION) on $(target)." >>Version.tcl
	echo "# Built on `date`, build system: `uname -n -m`" >>Version.tcl
	echo "#" >>Version.tcl
	echo "" >>Version.tcl
	echo "namespace eval Version {" >>Version.tcl
	echo "    variable VERSION {$(VERSION)}" >>Version.tcl
	echo "    variable target  {$(target)}"  >>Version.tcl
	echo "    variable build   {`date +%Y%m%d%H%M`-`uname -n`-`uname -m`}" >>Version.tcl
	echo "}" >>Version.tcl
	echo "package provide Version $(VERSION)" >>Version.tcl


