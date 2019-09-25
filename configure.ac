AC_INIT(GenerateStripboard,0.0.2,[support@deepsoft.com], GenerateStripboard)
AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_SUBST(build)
AC_CANONICAL_TARGET
AC_SUBST(target)
AC_CONFIG_SRCDIR(Scripts/GenerateStripboard.tcl)
AM_INIT_AUTOMAKE([-Wno-portability tar-ustar])

dnl Force cross_compiling, even if it *looks* like we can run cross-built 
dnl binaries (get around wine's cleverness).
if test ${cross_compiling} = "maybe"; then
  if test ${target_os} != ${build_os}; then
    cross_compiling=yes
  fi
fi  
        
AC_CONFIG_MACRO_DIR([m4])

if test "x${prefix}" = "xNONE"; then
    prefix=/usr/local
fi
if test "x${exec_prefix}" = "xNONE"; then
    exec_prefix="${prefix}"
fi

BUILD_DIR=`pwd`
TOP_DIR=${BUILD_DIR}

AC_SUBST(TOP_DIR)
AC_SUBST(BUILD_DIR)

srcdir=`dirname $0`
cd $srcdir
SRC_DIR=`pwd`
cd $BUILD_DIR

AC_SUBST(SRC_DIR)

AC_SUBST(target)

AX_PKG_DOXYGEN(1.6.0, [], [ AC_MSG_ERROR([DOXYGEN 1.6.0 is required to build.]) ])
dnl Checks for libraries.

PKG_PROG_PKG_CONFIG()
if test ${cross_compiling} = "yes"; then
  xcprefix1="`$CC -v 2>&1 | grep prefix`"
  dnl AC_MSG_NOTICE([*** xcprefix1 is ${xcprefix1}])
  xcprefix2="`echo ${xcprefix1}|sed 's/^.*--prefix=//g'`"
  dnl AC_MSG_NOTICE([*** xcprefix2 is ${xcprefix2}])
  xcprefix="`echo ${xcprefix2}|sed 's/[[[:space:]]].*$//g'`"
  dnl AC_MSG_NOTICE([*** xcprefix is ${xcprefix}])
  export PKG_CONFIG_PATH="${xcprefix}/lib/pkgconfig:${xcprefix}/share/pkgconfig"
  dnl AC_MSG_NOTICE([PKG_CONFIG_PATH is $PKG_CONFIG_PATH])
  m4_pattern_allow(PKG_CONFIG_LIBDIR)
  export PKG_CONFIG_LIBDIR="${xcprefix}/lib/pkgconfig:${xcprefix}/share/pkgconfig"
  dnl AC_MSG_NOTICE([PKG_CONFIG_LIBDIR is $PKG_CONFIG_PATH])
fi

AM_CONDITIONAL(TARGET_IS_LINUX, test ${target_os} = "linux-gnu")

dnl Pure Tcl code libraries
TEA_INIT([3.5])
TEA_PATH_TCLCONFIG
TEA_LOAD_TCLCONFIG
TEA_PROG_TCLSH
if test ${cross_compiling} = "no"; then
  HOSTTCLSH=${TCLSH_PROG}
else
  AC_PATH_PROGS(HOSTTCLSH,[tclsh8.5 tclsh])
fi
AX_SNIT
AX_CSV
AX_STRUCT
AX_TCLLOG
AX_URI

AC_PATH_PROGS(UNZIP,unzip)

AC_MSG_CHECKING([Checking target tclkit])
case $target_os in 
  macos | darwin*) 
    AC_SUBST(TCLKITRUN, tclkit-darwin-univ-aqua)
    AC_SUBST(KIT_EXTRA_CFLAGS,['-arch i386 -arch x86_64'])
    AC_SUBST(BINTRUE,[/usr/bin/true])
    ;;
  linux-gnu*)
    case $target_cpu in
      x86_64)
	AC_SUBST(TCLKITRUN, tclkit-linux-x86_64)
	;;
      i*86)
	AC_SUBST(TCLKITRUN, tclkit-linux-x86)
	;;
      arm*)
        AC_SUBST(TCLKITRUN, tclkit-linux-armv7l)
        ;;
      *)
	AC_MSG_ERROR([Unsupported Linux arch: $target_cpu])
	;;
     esac
     AC_SUBST(KIT_EXTRA_CFLAGS,[])
     AC_SUBST(NEED_APP_BUNDLE,[false])
     AC_SUBST(BINTRUE,[/bin/true])
     ;;

   mingw32* | winnt | windows* | cygwin)
     AC_SUBST(TCLKITRUN, tclkit-win32.exe)
     AC_SUBST(EXEEXT, .exe)
     AC_SUBST(KIT_EXTRA_CFLAGS,[])
     AC_SUBST(NEED_APP_BUNDLE,[false])
     AC_SUBST(BINTRUE,[/bin/true])
     ;;
   *) 
     AC_MSG_ERROR([Unsupported Operating System: $target_os])
     ;;
esac
AC_MSG_RESULT([TCLKITRUN is $TCLKITRUN])
AM_CONDITIONAL(MACOSX, test x${NEED_APP_BUNDLE} = xtrue)                        

AC_PATH_PROG(PDFLATEX,pdflatex,$BINTRUE)
AC_PATH_PROG(LATEX,latex,$BINTRUE)
AC_PATH_PROG(MAKEINDEX,makeindex,$BINTRUE)
AC_PATH_PROG(BIBTEX,bibtex,$BINTRUE)
AC_PATH_PROG(DVIPS,dvips,$BINTRUE)
AC_PATH_PROG(PS2PDF,ps2pdf,$BINTRUE)

AC_MSG_CHECKING([Checking build tclkit])
case $build_os in 
  macos | darwin*) 
    AC_SUBST(TCLKITBSRC, tclkit-darwin-univ-aqua)
    AC_SUBST(BEXEEXT, )
    ;;
  linux-gnu*)
    AC_SUBST(BEXEEXT, )
    case $build_cpu in
      x86_64)
	AC_SUBST(TCLKITBSRC, tclkit-linux-x86_64)
	;;
      i*86)
	AC_SUBST(TCLKITBSRC, tclkit-linux-x86)
	;;
      arm*)
        AC_SUBST(TCLKITBSRC, tclkit-linux-armv7l)
        ;;
      *)
	AC_MSG_ERROR([Unsupported Linux arch: $build_cpu])
	;;
     esac
     ;;

   mingw32* | winnt | windows* | cygwin)
     AC_SUBST(BEXEEXT, .exe)
     AC_SUBST(TCLKITBSRC, tclkit-win32.exe)
     ;;
   *) 
     AC_MSG_ERROR([Unsupported Operating System: $build_os])
     ;;
esac
AC_MSG_RESULT([TCLKITBSRC is $TCLKITBSRC])


AC_PATH_PROG(SED,sed)

AC_CONFIG_FILES([ \
	  Makefile \
	  BuildScripts/Makefile \
	  BuildData/Makefile \
	  Scripts/Makefile \
	  ExtraDoc/Makefile \
	  Doxyfile \
	  BuildScripts/tcldoxyfilter.sh])
AC_CONFIG_COMMANDS([default],[chmod +x BuildScripts/tcldoxyfilter.sh])
AC_OUTPUT



