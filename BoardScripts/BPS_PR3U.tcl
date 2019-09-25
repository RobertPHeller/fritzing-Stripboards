#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Sep 25 12:03:53 2019
#  Last Modified : <190925.1508>
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


snit::type BPS_PR3U {
    # Use the macro to include the component
    Board "BusBoard Prototype Systems BPS PR3U Stripboard"
    constructor {args} {
        # Install the component, customizing the metadata.
        install board using GenericStripboard ${selfns}%AUTO% \
              -version 1.0 \
              -author "Robert Heller" \
              -title "BPS PR3U" \
              -moduleid "BPS_PR3U" \
              -label PR3U \
              -description {* ProtoBoard saves time! ProtoBoard has a
            general purpose stripboard circuit pattern
            that is pre-cut with 6 holes per segment.
            
            *· 0.1" hole spacing for DIP integrated circuits
            and headers.
            
            *· Standard single height (3U) Eurocard/VME
            size. Many off the shelf enclosures and card
            cages are available.
            
            *· Accepts a 96 pin DIN-41612 VME
            connector for backplane or board-to-board
            connections. Holes for ejector latches.
            Rows 1 and 3 are routed to separate pads.
            Row 2 is unconnected.

            *· ProtoBoard-3U uses a high-quality FR4
            glass epoxy board. It has better stability and
            moisture resistance than boards using
            phenolic or SRBP (synthetic resin bonded
            paper) to avoid warping.} \
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
            # the first three rows and the last three rows have ten 6-hole 
            # buses.
            # The first two and last two have a hole missing at the back for
            # board ejector clearence and the second and next to last are 
            # missing a hole at the front end because of the connector mounting
            # holes.
            if {$row <= 3 || $row >= 36} {
                if {$row < 3 || $row > 36} {
                    incr x 254
                    set start_i 1
                } else {
                    set start_i 0
                }
                set count 0
                for {set b 1} {$b < 11} {incr b} {
                    set x1 $x
                    for {set i $start_i} {$i < 6} {incr x 254;incr i} {
                        set col [format {%c} [expr {$b + 65}]]
                        $board AddHole $x $y 47 ${row}${col}$i ${row}${col}
                        incr count
                        set x2 $x
                        if {($row == 2 || $row == 37) && $count == 58} {break}
                    }
                    set start_i 0
                    $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                }
            } else {
                # The middle 32 rows only have nine 6-hole buses, plus short 
                # buses for the 96-pin (32x3) DIN-41612 VME connector.
                set count 0
                for {set b 1} {$b < 10} {incr b} {
                    set x1 $x
                    for {set i 0} {$i < 6} {incr x 254;incr i} {
                        set col [format {%c} [expr {$b + 65}]]
                        $board AddHole $x $y 47 ${row}${col}$i ${row}${col}
                        incr count
                        set x2 $x
                    }
                    $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                }
                # Process one column of the connector.
                set x1 $x
                $board AddHole $x $y 44.45 3C${connCol}A 3C$connCol
                incr x 254
                incr count
                $board AddHole $x $y 44.45 3C${connCol}B 3C$connCol
                set x2 $x
                set C3_x1 $x
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                incr x 254
                incr count
                set x1 $x
                $board AddHole $x $y 44.45 1C${connCol}A 1C$connCol
                incr x 254 
                incr count
                $board AddHole $x $y 44.45 1C${connCol}B 1C$connCol
                set x2 $x
                $board AddLine $x1 $y $x2 $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                incr x 254
                incr count
                $board AddHole $x $y 44.45 2C${connCol} 2C$connCol
                incr x 254
                incr count
                $board AddHole $x $y 44.45 3C${connCol}C 3C$connCol
                $board AddLine $x $y $x $y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                set C3_x2 $x
                set C3_y [expr {$y - 127}]
                #puts stderr "*** $type create $self: C3_x1 = $C3_x1, C3_y = $C3_y, C3_x2 = $C3_x2"
                $board AddLine $C3_x1 $C3_y $C3_x2 $C3_y brown 30 "stroke-opacity:.5;"
                $board AddLine $C3_x1 $C3_y $C3_x1 $y brown 30 "stroke-linecap:butt;stroke-opacity:.5;"
                $board AddLine $C3_x2 $C3_y $C3_x2 $y brown 30 "stroke-linecap:butt;stroke-opacity:.5;"
                incr x 254
                incr count
                incr connCol
            }
            #puts stderr "*** $type create $self: row = $row, count = $count"
        }
    }
}
    
            




set test [BPS_PR3U create %AUTO%]
#$test WriteFZP [$test cget -moduleid].fzp
#$test WriteBBSVG [$test cget -label].svg
$test WriteFZPZ [$test cget -moduleid].fzpz
