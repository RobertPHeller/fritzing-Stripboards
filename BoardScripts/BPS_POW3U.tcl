#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Sep 25 18:34:39 2019
#  Last Modified : <190925.2001>
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


snit::type BPS_POW3U {
    # Use the macro to include the component
    Board "BusBoard Prototype Systems BPS POW3U Stripboard"
    proc _letterColumn {column} {
        if {$column >= 1 && $column <= 26} {
            #puts stderr "*** _letterColumn: $column is between 1 and 26"
            return [format {%c} [expr {64 + $column}]]
        } elseif {$column >= 27 && $column <= 52} {
            #puts stderr "*** _letterColumn: $column is between 27 and 52"
            return [format {%c} [expr {96 + ($column - 26)}]]
        } else {
            #puts stderr "*** _letterColumn: $column is greater than 52"
            set ch [expr {64 + ($column - 52)}]
            return [format {%c%c} $ch $ch]
        }
    }
    constructor {args} {
        # Install the component, customizing the metadata.
        install board using GenericStripboard ${selfns}%AUTO% \
              -version 1.0 \
              -author "Robert Heller" \
              -title "BPS POW3U" \
              -moduleid "BPS_POW3U" \
              -label POW3U \
              -description {* PowerBoard has interleaved power and
            ground rails to easily distribute power to
            your circuits.
        
            * The general purpose strip board circuit
            pattern with 6 holes per strip is good for
            general purpose analog and digital use.
        
            * 0.1" hole spacing for DIP integrated circuits
            and headers.
        
            * Standard single height (3U) Eurocard/VME
            size. Many off the shelf enclosures and card
            cages are available
        
            * Accepts a 96 pin DIN-41612 VME
            connector for backplane or board-to-board
            connections. Holes for ejector latches.
            Rows 1 and 3 are routed to separate pads.
            Row 2 is unconnected.
        
            * Drilled holes for ejector latches.} \
            -units mm -width 160 -height 100 \
            -viewport {0 0 16000 10000}
        # Mounting and board ejector holes (non-connector holes).
        $board AddHole 350 508 76.2
        $board AddHole 350 9492 76.2
        $board AddHole 15750 508 200
        $board AddHole 15750 9492 200
        # Vertical strip at the back of the board
        for {set y 762;set r 3} {$r <= 36} {incr y 254;incr r} {
            $board AddHole 175 $y 47 ${r}A A
        }
        $board AddLine 175 762 175 [expr {$y - 254}] brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                # Now do the batches of horizontal strips
        set connCol 1
        set y 0
        for {set row 1} {$row <= 38} {incr row} {
            set x [expr {175 + 254}]
            incr y 254
            # The first and last row are 60 hole strips
            if {$row == 1 || $row == 38} {
                incr x 254
                set x1 $x
                for {set b 3} {$b < 62} {incr b} {
                    set col [_letterColumn $b]
                    $board AddHole $x $y 47 ${row}${col} $row
                    set x2 $x
                    incr x 254
                }
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
            } elseif {$row == 2 || $row == 37} {
                # The second and next to last are 59 hole strips and part of 
                # the power / ground buses
                incr x 254
                set x1 $x
                if {$row == 2} {
                    set ypA1 $y
                    #set ypB1 [expr {$y + 254}]
                    set bus P1
                } else {
                    #set ypA2 [expr {$y - 254}]
                    set ypB2 $y
                    set bus P2
                }
                set x1 $x
                for {set b 3} {$b < 61} {incr b} {
                    set col [_letterColumn $b]
                    $board AddHole $x $y 47 ${row}${col} $bus
                    set x2 $x
                    incr x 254
                }
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
            } elseif {$row == 3 || $row == 36} {
                # The third and third from the last have eight six hole buses, 
                # four pairs of vertical power buses and four hole bus
                if {$row == 3} {
                    set ypB1 $y
                } else {
                    set ypA2 $y
                }
                set pIndex 0
                for {set b 1} {$b <= 8} {incr b} {
                    set col [_letterColumn $b]
                    set x1 $x
                    set bus ${row}${col}
                    for {set i 1} {$i <= 6} {incr i} {
                        $board AddHole $x $y 47 ${bus}$i $bus
                        set x2 $x
                        incr x 254
                    }
                    $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    if {($b&1) == 1} {
                        $board AddHole $x $y 47 ${row}P1_$pIndex P1
                        set xpA($pIndex) $x
                        incr x 254
                        $board AddHole $x $y 47 ${row}P2_$pIndex P2
                        set xpB($pIndex) $x
                        incr x 254
                        incr pIndex
                    }
                }
                set col [_letterColumn $b]
                set x1 $x
                set bus ${row}${col}
                for {set i 1} {$i <= 4} {incr i} {
                    $board AddHole $x $y 47 ${bus}$i $bus
                    set x2 $x
                    incr x 254
                }
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
            } else {
                # And the rest have the DIN-41612 connector...
                set pIndex 0
                for {set b 1} {$b <= 7} {incr b} {
                    set col [_letterColumn $b]
                    set x1 $x
                    set bus ${row}${col}
                    for {set i 1} {$i <= 6} {incr i} {
                        $board AddHole $x $y 47 ${bus}$i $bus
                        set x2 $x
                        incr x 254
                    }
                    $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    if {($b&1) == 1} {
                        $board AddHole $x $y 47 ${row}P1_$pIndex P1
                        incr x 254
                        $board AddHole $x $y 47 ${row}P2_$pIndex P2
                        incr x 254
                        incr pIndex
                    }
                }
                set bus 3C$connCol
                set x1 $x
                for {set i 1} {$i <= 6} {incr i} {
                    $board AddHole $x $y 47 ${bus}[_letterColumn $i] $bus
                    set x2 $x
                    set C3_x1 $x
                    incr x 254
                }
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                $board AddHole $x $y 44.45 1C${connCol}A 1C$connCol
                set x1 $x
                incr x 254 
                $board AddHole $x $y 44.45 1C${connCol}B 1C$connCol
                set x2 $x
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                incr x 254
                $board AddHole $x $y 44.45 2C${connCol} 2C$connCol
                incr x 254
                $board AddHole $x $y 44.45 3C${connCol}G 3C$connCol
                $board AddLine $x $y $x $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                set C3_x2 $x
                set C3_y [expr {$y - 127}]
                #puts stderr "*** $type create $self: C3_x1 = $C3_x1, C3_y = $C3_y, C3_x2 = $C3_x2"
                $board AddLine $C3_x1 $C3_y $C3_x2 $C3_y brown 30 "stroke-opacity:.5;"
                $board AddLine $C3_x1 $C3_y $C3_x1 $y brown 30 "stroke-linecap:butt;stroke-opacity:.5;"
                $board AddLine $C3_x2 $C3_y $C3_x2 $y brown 30 "stroke-linecap:butt;stroke-opacity:.5;"
                incr x 254
                incr connCol
            }
        }
        foreach pIndex [array names xpA] {
            $board AddLine $xpA($pIndex) $ypA1 $xpA($pIndex) $ypA2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        }
        foreach pIndex [array names xpB] {
            $board AddLine $xpB($pIndex) $ypB1 $xpB($pIndex) $ypB2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        }
    }
}

set b [BPS_POW3U create %AUTO%]
$b WriteFZPZ [$b cget -moduleid].fzpz

        
