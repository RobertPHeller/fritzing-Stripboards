#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Sep 24 16:18:32 2019
#  Last Modified : <190925.1227>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
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
#*****************************************************************************

##
#
# @mainpage Introduction
# This program generates "stripboards", solderable prototyping boards that have
# strips of copper foil connecting groups of holes, generally on .1 inch 
# (2.54mm) centers.  There are many such boards, ranging from ones that are
# pad-per-hole (no actually strips) to ones with power buses and arranged with 
# 2 to 6 hole long strips.  Some have patterns to take connectors and/or have
# edge connector fingers.
#
# This program is not a GUI program. It is purely command line and in order to
# use it, it is needful to know some basic Tcl.  The user creates a Tcl script
# file that defines the board and its pattern on holes and copper.
#
# @defgroup GenerateStripboard Generate Stripboard
# Create Stripboard part objects for Fritzing
#
# @section SYNOPSIS SYNOPSIS
#
# GenerateStripboard [options] [scriptfiles...]
#
# @section DESCRIPTION DESCRIPTION
# 
# This program generates "stripboards", solderable prototyping boards that have
# strips of copper foil connecting groups of holes, generally on .1 inch 
# (2.54mm) centers.  There are many such boards, ranging from ones that are
# pad-per-hole (no actually strips) to ones with power buses and arranged with 
# 2 to 6 hole long strips.  Some have patterns to take connectors and/or have
# edge connector fingers.
#
# This program is not a GUI program. It is purely command line and in order to
# use it, it is needful to know some basic Tcl.  The user creates a Tcl script
# file that defines the board and its pattern on holes and copper.
#
# @section OPTIONS OPTIONS
#
# @arg -help Display a brief help (usage) text and exit.
# @arg -copying Display the program's license and exit.
# @arg -warrantry Display the program's warrantry and exit.
# @arg -version Display the program's version and exit.
# @par
#
# @section PARAMETERS PARAMETERS
#
# One or more board script file.
#
# @section FritzingPartsSVGEditorAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#
# @page BoardGenApi Board Generation API
# @{

package require snit
package require ParseXML
package require ZipArchive
package require vfs::zip
package require vfs::mk4
package require Version

set argv0 [file join [file dirname [info nameofexecutable]] [file rootname [file tail [info script]]]]

# Viewport type: exactly four doubles
snit::listtype ViewPort -type snit::double -minlen 4 -maxlen 4
# Units enum: mm or inch
snit::enum Units -values {inch mm}
# SizeType: positive non-zero double
snit::double SizeType -min 1.0

snit::type GenericStripboard {
    typevariable _fzpTemplate {<module moduleId="%moduleId">
        <version />
        <author />
        <title />
        <date />
        <label />
        <tags />
        <properties />
        <taxonomy />
        <description />
        <views>
          <iconView>
            <layers image="breadboard/%breadboard.svg">
              <layer layerId="icon"/>
            </layers>
          </iconView>
          <breadboardView>
            <layers image="breadboard/%breadboard.svg">
              <layer layerId="breadboard"/>
            </layers>
          </breadboardView>
          <schematicView>
            <layers image="breadboard/%breadboard.svg">
              <layer layerId="breadboard"/>
            </layers>
          </schematicView>
          <pcbView>
            <layers image="breadboard/%breadboard.svg">
              <layer layerId="breadboard"/>
            </layers>
          </pcbView>
        </views>
        <connectors ignoreTerminalPoints="true" />
        <buses />
        </module>}
    variable _fzp
    variable _tags 
    method AddTag {tag} {
        set t [SimpleDOMElement create %AUTO% -tag tag]
        $t setdata $tag
        $_tags addchild $t
    }
    variable _properties 
    method AddProperty {name property} {
        set p [SimpleDOMElement create %AUTO% -tag property -attributes [list name $name]]
        $p setdata $property
        $_properties addchild $p
    }
    variable _connectors
    method AddConnection {cx cy r connName} {
        set connector [SimpleDOMElement create %AUTO% -tag connector \
                       -attributes [list type female name $connName id [format {connector%s} $connName]]]
        $_connectors addchild $connector
        set views [SimpleDOMElement create %AUTO% -tag views]
        $connector addchild $views
        set bbview [SimpleDOMElement create %AUTO% -tag breadboardView]
        $views addchild $bbview
        set svgId [format {connector%spin} $connName]
        set p [SimpleDOMElement create %AUTO% -tag p \
               -attributes [list layer breadboard svgId $svgId]]
        $bbview addchild $p
    }
    variable _buses
    method AddBus {connName busName} {
        set member [SimpleDOMElement create %AUTO% -tag nodeMember \
                    -attributes [list connectorId [format {connector%s} $connName]]]
        foreach b [$_buses getElementsByTagName bus -depth 1] {
            if {[$b attribute id] eq $busName} {
                $b addchild $member
                return
            }
        }
        set b [SimpleDOMElement  create %AUTO% -tag bus -attributes [list id $busName]]
        $_buses addchild $b
        $b addchild $member
    }
    variable _module
    typevariable _breadboardSVGTemplate {<svg xmlns="http://www.w3.org/2000/svg" >
        <g id="breadboard" />
        </svg>}
    variable _breadboardSVGroot
    variable _breadboardSVG
    variable _breadboardbreadboardGroup
    method _initializeXML {} {
        set _fzp [ParseXML %AUTO% $_fzpTemplate]
        set _module [$_fzp getElementsByTagName module -depth 1]
        set moduleId [$_module attribute moduleId]
        $_module setAttribute moduleId [regsub -all {%moduleId} $moduleId [$self cget -moduleid]]
        foreach l [$_module getElementsByTagName layers] {
            set image [$l attribute image]
            $l setAttribute image [regsub -all {%breadboard} [$l attribute image] [$self cget -label]]
        }
        [$_module getElementsByTagName version -depth 1] setdata [$self cget -version]
        [$_module getElementsByTagName author -depth 1] setdata [$self cget -author]
        [$_module getElementsByTagName title -depth 1] setdata [$self cget -title]
        [$_module getElementsByTagName date -depth 1] setdata [clock format [clock seconds]]
        [$_module getElementsByTagName label -depth 1] setdata [$self cget -label]
        [$_module getElementsByTagName taxonomy -depth 1] setdata [$self cget -taxonomy]
        [$_module getElementsByTagName description -depth 1] setdata [$self cget -description]
        set _tags [$_module getElementsByTagName tags -depth 1]
        set _properties [$_module getElementsByTagName properties -depth 1]
        $self AddProperty size [format {%f%s X %f%s} [$self cget -width] [$self cget -units] [$self cget -height] [$self cget -units]]
        $self AddProperty family "Generic Stripboard"
        set _connectors [$_module getElementsByTagName connectors -depth 1]
        set _buses [$_module getElementsByTagName buses -depth 1]
        set _breadboardSVGroot [ParseXML %AUTO% $_breadboardSVGTemplate]
        set _breadboardSVG [$_breadboardSVGroot getElementsByTagName svg]
        $_breadboardSVG setAttribute width [format {%f%s} [$self cget -width] [$self cget -units]]
        $_breadboardSVG setAttribute height [format {%f%s} [$self cget -height] [$self cget -units]]
        $_breadboardSVG setAttribute viewBox [format {%s} [$self cget -viewport]]
        set groups [$_breadboardSVG getElementsByTagName g -depth 1]
        foreach g $groups {
            if {[$g attribute id] eq "breadboard"} {
                set _breadboardLayerGroup $g
                break
            }
        }
    }
    variable _boardOutlinePath
    variable _boardColor #deb675
    variable _breadboardLayerGroup
    method _initializeBoardOutlinePath {} {
        lassign [$self cget -viewport] x1 y1 x2 y2
        set _boardOutlinePath [format {M%g,%gL%g,%g %g,%g %g,%gz} \
                               $x1 $y1 $x2 $y1 $x2 $y2 $x1 $y2]
        set outline [SimpleDOMElement create %AUTO% -tag path \
                                         -attributes [list id boardoutline \
                                                      stroke-width 0 \
                                                      stroke none \
                                                      fill $_boardColor \
                                                      fill-opacity 1 \
                                                      d $_boardOutlinePath]]
        $_breadboardLayerGroup addchild $outline
        
    }
    option -units -type Units -default mm -readonly yes
    option -viewport -type ViewPort -default {0 0 254 254} -readonly yes
    option -width -type SizeType -default 25.4 -readonly yes
    option -height -type SizeType -default 25.4 -readonly yes
    option -moduleid -default "StripboardModuleID" -readonly yes
    option -version -default 1.0 -readonly yes
    option -author -default "Robert Heller" -readonly yes
    option -title -default "A Random Stripboard" -readonly yes
    option -label -default "JRandomStripboard" -readonly yes
    option -taxonomy -default "prototyping.perfboard.perfboard" -readonly yes
    option -description -default {} -readonly yes
    constructor {args} {
        $self configurelist $args
        $self _initializeXML
        $self _initializeBoardOutlinePath
    }
    method WriteFZP {filename} {
        if {[catch {open $filename w} fp]} {
            error [format {Could not open %s for writing: %s} $filename $fp]
        }
        xmlheader $fp
        $_fzp displayTree $fp
        close $fp
    }
    method WriteBBSVG {filename} {
        if {[catch {open $filename w} fp]} {
            error [format {Could not open %s for writing: %s} $filename $fp]
        }
        foreach p [$_breadboardLayerGroup getElementsByTagName path -depth 1] {
            if {[$p attribute id] eq "boardoutline"} {
                set outline $p
                break
            }
        }
        set boardoutlinepath $_boardOutlinePath
        foreach h $_holes {
            lassign $h cx cy r connName
            set x0 [expr {$cx - $r}]
            set d  [expr {$r * 2}]
            append boardoutlinepath [format "\nM%g,%ga%g,%g 0 1 0 %g,0 %g,%g, 0 1 0 -%g,0z" \
                                     $x0 $cy $r $r $d $r $r $d]
            if {$connName eq ""} {continue}
            set svgId [format {connector%spin} $connName]
            set connectioncirc [SimpleDOMElement create %AUTO% -tag circle \
                                -attributes [list id $svgId \
                                             cx [format {%g} $cx] \
                                             cy [format {%g} $cy] \
                                             r  [format {%g} $r] \
                                             stroke-width [format {%g} [expr {$r * .75}]] \
                                             stroke brown \
                                             fill none]]
            $_breadboardLayerGroup addchild $connectioncirc
        }
        $outline setAttribute d $boardoutlinepath
        xmlheader $fp
        $_breadboardSVGroot displayTree $fp
        close $fp
    }
    proc xmlheader {fp} {
        puts $fp {<?xml version="1.0" encoding="utf-8"?>}
    }
    typevariable TmpDir
    typeconstructor {
        global tcl_platform
        switch $tcl_platform(platform) {
            windows {
                if {[info exists env(TEMP)]} {
                    set TmpDir $env(TEMP)
                } elseif {[info exists env(TMP)]} {
                    set TmpDir $env(TMP)
                } else {
                    set TmpDir $env(SystemDrive)
                }
            }
            unix {
                if {[info exists env(TMPDIR)]} {
                    set TmpDir $env(TMPDIR)
                } else {
                    set TmpDir /tmp
                }
            }
        }
    }
    typevariable _genindex 0
    typemethod _genname {class} {
        incr _genindex
        return [format {%s%05d} [string toupper $class] $_genindex]
    }
    method WriteFZPZ {filename {comment {Generic Stripboard}}} {
        set path [$type _genname FZPZ]
        set tempfile [file join $TmpDir $path]
        while {[file exists $tempfile]} {
            set path [$type _genname FZPZ]
            set tempfile [file join $TmpDir $path]
        }
        vfs::mk4::Mount $tempfile /$path
        $self WriteFZP [file join /$path "part.[$self cget -moduleid].fzp"]
        $self WriteBBSVG [file join /$path "svg.breadboard.[$self cget -label].svg"]
        ::ZipArchive createZipFromDirtree $filename /$path \
              -comment $comment
        vfs::unmount /$path
        file delete $tempfile
    }
    method DefineOutline {polypoints {color #deb675}} {
        set _boardColor $color
        set path [format {M%g,%g} [lindex $polypoints 0] [lindex $polypoints 1]]
        set ch {L}
        foreach x y [lrange $polypoints 2 end] {
            append path [format {%s%g,%g} $ch $x $y]
            set ch { }
        }
        append path {z}
        foreach p [$_breadboardLayerGroup getElementsByTagName path -depth 1] {
            if {[$p attribute id] eq "boardoutline"} {
                set outline $p
                break
            }
        }
        $outline setAttribute d $path
        $outline setAttribute fill $_boardColor
    }
    variable _holes [list]
    method AddHole {cx cy r {connectionId {}} {bus {}}} {
        lappend _holes [list $cx $cy $r $connectionId]
        if {$connectionId ne {}} {
            $self AddConnection $cx $cy $r $connectionId
            if {$bus ne {}} {
                $self AddBus $connectionId $bus
            }
        }
    }
    method AddLine {x1 y1 x2 y2 color width {style {}}} {
        set l [SimpleDOMElement create %AUTO% -tag line \
               -attributes [list x1 $x1 y1 $y1 x2 $x2 y2 $y2 \
                            stroke $color stroke-width $width]]
        if {$style ne {}} {$l setAttribute style $style}
        $_breadboardLayerGroup addchild $l
    }
    method AddText {x y text {color white} {height 10} {font OCRA} {style {}}} {
        set t [SimpleDOMElement create %AUTO% -tag text \
               -attributes [list x $x y $y stroke none fill $color \
                            font-size $height font-family $font]]
        if {$style ne {}} {$t setAttribute style $style}
        $t setdata $text
        $_breadboardLayerGroup addchild $t
    }
    proc usage {program} {
        puts stderr "$program \[options...\] \[parameters...\]\n"
        puts stderr "Where options can be:"
        puts stderr "\t-help - Display a brief help (usage) text and exit."
        puts stderr "\t-copying - Display the program's license and exit."
        puts stderr "\t-warrantry - Display the program's warrantry and exit."
        puts stderr "\t-version - Display the program's version and exit."
        puts stderr "\nParameters are one or more Tcl script files defining boards."
        exit 1
    }
    proc Copying {} {
        set copyfp [open [file join [file dirname \
                                     [file dirname \
                                      [file dirname \
                                       [info script]]]] License COPYING] r]
        puts -nonewline stderr [read $copyfp]
        close $copyfp
        exit 1
    }
    proc Warrantry {} {
        set copyfp [open [file join [file dirname \
                                     [file dirname \
                                      [file dirname \
                                       [info script]]]] License COPYING] r]
        while {[gets $copyfp line] >= 0} {
            if {[regexp {15\. Disclaimer of Warranty\.} $line] > 0} {
                break
            }
        }
        puts stderr $line
        while {[gets $copyfp line] >= 0} {
            if {[regexp {END OF TERMS AND CONDITIONS} $line] > 0} {
                break
            }
            puts stderr $line
        }
        close $copyfp 
        exit 1
    }
    proc Version {program} {
        puts stderr "This is version $Version::VERSION of [file tail $program]."
        puts stderr "Build $Version::build for target $Version::target."
        exit 1
    }
    typemethod Main {program argv} {
        set scripts [list]
        foreach arg $argv {
            switch -glob $arg {
                -h* {usage $program}
                -copy* {Copying}
                -warrantry {Warrantry}
                -v* {Version $program}
                -* {
                    puts stderr "$program: unknown option: $arg\n"
                    usage $program
                }
                default {
                    lappend scripts $arg
                }
            }
        }
        foreach script $scripts {
            source $script
        }
        exit 0
    }
    
}

snit::macro Board {comment} {
    component board
    delegate option * to board
    typevariable _comment $comment
    method WriteFZPZ {filename} {
        $board WriteFZPZ $filename $_comment
    }
}

## @}

GenericStripboard Main $::argv0 $::argv
