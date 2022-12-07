#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Dec 5 12:01:00 2022
#  Last Modified : <221205.1313>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2022  Robert Heller D/B/A Deepwoods Software
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


snit::type SP1_50x50_G {
    # Use the macro to include the component
    Board "BusBoard Prototype Systems SP1-50x50-g SMTpads board"
    constructor {args} {
        # Install the component, customizing the metadata.
        install board using GenericStripboard ${selfns}%AUTO% \
              -version 1.0 \
              -author "Robert Heller" \
              -title "SP1-50x50-g" \
              -moduleid "SP1-50x50-g" \
              -label "SP1-50x50-g" \
              -description {SMTpads...} \
              -units mm -width 80 -height 50 \
              -viewport {0 0 8000 5000}
        # Mounting holes (non-connector holes).
        $board AddHole 444.5 444.5 150
        $board AddHole 444.5 [expr {4953-444.5}] 150
        $board AddHole [expr {8001-444.5}] [expr {4953-444.5}] 150
        $board AddHole [expr {8001-444.5}] 444.5 150
        scan A %c A
        for {set i 0} {$i < 63} {incr i} {
            set rowHasHoles [expr {(($i-1)%4) == 0}]
            set mHoleRow [expr {$i == 3 || $i == 59}]
            for {set j 0} {$j < 39} {incr j} {
                set mHoleColumn [expr {$j == 3 || $j == 35}]
                if {$mHoleRow && $mHoleColumn} {continue}
                set hasHole [expr {($j%4) == 0 && $rowHasHoles}]
                set connName [format {%c%d} [expr {$j+$A}] $i]
                set r 0
                if {$hasHole} {set r 38}
                $board AddPad [expr {($i * 127)+63.5}] [expr {($j * 127)+63.5}] 107 107 $connName $r
            }
        }
    }
}

                
                    
set test [SP1_50x50_G create %AUTO%]
$test WriteFZPZ [$test cget -moduleid].fzpz
