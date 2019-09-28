#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Sep 27 18:48:13 2019
#  Last Modified : <190927.2114>
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


snit::type BPS_BR1 {
    # Use the macro to include the component
    Board "BusBoard Prototype Systems BPS BR1 Solderable PC BreadBoard"
    constructor {args} {
        # Install the component, customizing the metadata.
        install board using GenericStripboard ${selfns}%AUTO% \
              -version 1.0 \
              -author "Robert Heller" \
              -title "BPS BR1" \
              -moduleid "BPS_BR1" \
              -label BR1 \
              -description {* Transfer your circuit and wires without
            recutting wires or changing your layout.
            
            The BR1 Solderable BreadBoard has the
            same pattern and spacing as a standard 830
            connection point solderless breadboard.
            
            * Soldered joints provide a more reliable
            longterm connection than solderless
            contacts.
            
            * Standard 5-hole strip for each IC pin, just
            like solderless breadboards.
            
            * Four power rails like solderless breadboards
            plus two bonus rails for power or signals.
            
            * Bonus two-hole pads along the centerline
            allow DIL (dual in-line) headers to be used.
            
            * Lead free etched copper PCB with an
            anti-tarnish coating for easy soldering.
            
            * 0.1" hole spacing for DIP integrated circuits
            and headers.
            
            * Four PCB mounting holes provided.} \
            -units mm -width 179 -height 47 \
            -viewport {0 0 17872 4700}
        # Mounting holes
        $board AddHole 300 445 175
        $board AddHole 17572 445 175
        $board AddHole 17572 4255 175
        $board AddHole 300 4255 175
        for {set col 1;set x 300} {$col < 70} {incr col;incr x 254} {
            # Pad-per-hole holes at the ends
            if {$col == 1 || $col == 69} {
                # Column 1/69
                for {set r 4;set y [expr {445 + 508}]} {$r < 16} {incr r;incr y 254} {
                    $board AddHole $x $y 53.5 [row2letter $r]$col
                }
            } elseif {$col == 2 || $col == 68} {
                # Column 2/68
                    for {set r 3; set y [expr {445 + 254}]} {$r < 17} {incr r;incr y 254} {
                    $board AddHole $x $y 53.5 [row2letter $r]$col
                }
            } elseif {$col == 3  || $col == 4 ||
                      $col == 66 ||$col == 67} {
                # Column 3/66 -- start/end of strips (with longest power strips)
                if {$col == 3} {
                    set p1_x1 $x
                    set p6_x1 $x
                } elseif {$col == 67} {
                    set p1_x2 $x
                    set p6_x2 $x
                }
                for {set r 1;set y [expr {445 - 254}]} {$r < 19} {incr r;incr y 254} {
                    if {$r == 1} {
                        set bus P1
                        set p1_y $y
                    } elseif {$r == 2} {
                        set bus A${col}A
                        set y1 $y
                    } elseif {$r == 8} {
                        set y2 $y
                    } elseif {$r == 9} {
                        set y1 $y
                        set bus A${col}B
                    } elseif {$r == 10} {
                        set y2 $y
                    } elseif {$r == 11} {
                        set y1 $y
                        set bus A${col}C
                    } elseif {$r == 17} {
                        set y2 $y
                    } elseif {$r == 18} {
                        set bus P6
                        set p6_y $y
                    }
                    $board AddHole $x $y 53.5 [row2letter $r]${col} $bus
                    if {$r == 8} {
                        $board AddLine $x $y1 $x $y2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    } elseif {$r == 10} {
                        $board AddLine $x $y1 $x $y2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    } elseif {$r == 17} {
                        $board AddLine $x $y1 $x $y2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    }
                }
            } else {
                # Columns 5 though 65
                if {$col == 5} {
                    set p2_x1 $x
                    set p3_x1 $x
                    set p4_x1 $x
                    set p5_x1 $x
                } elseif {$col == 65} {
                    set p2_x2 $x
                    set p3_x2 $x
                    set p4_x2 $x
                    set p5_x2 $x
                }
                for {set r 1;set y [expr {445 - 254}]} {$r < 19} {incr r;incr y 254} {
                    if {$r == 1} {
                        set bus P1
                        set p1_y $y
                    } elseif {$r == 2} {
                        set bus P2
                        set p2_y $y
                    } elseif {$r == 3} {
                        set bus P3
                        set p3_y $y
                    } elseif {$r == 4} {
                        set bus A${col}A
                        set y1 $y
                    } elseif {$r == 8} {
                        set y2 $y
                    } elseif {$r == 9} {
                        set y1 $y
                        set bus A${col}B
                    } elseif {$r == 10} {
                        set y2 $y
                    } elseif {$r == 11} {
                        set y1 $y
                        set bus A${col}C
                    } elseif {$r == 15} {
                        set y2 $y
                    } elseif {$r == 16} {
                        set bus P4
                        set p4_y $y
                    } elseif {$r == 17} {
                        set bus P5
                        set p5_y $y
                    } elseif {$r == 18} {
                        set bus P6
                        set p6_y $y
                    }
                    $board AddHole $x $y 53.5 [row2letter $r]${col} $bus
                    if {$r == 8} {
                        $board AddLine $x $y1 $x $y2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    } elseif {$r == 10} {
                        $board AddLine $x $y1 $x $y2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    } elseif {$r == 15} {
                        $board AddLine $x $y1 $x $y2 brown 150 "stroke-linecap:round;stroke-opacity:.5;"
                    }
                }
            }
        }
        #puts stderr "*** $type create $self: x = $x"
        $board AddLine $p1_x1 $p1_y $p1_x2 $p1_y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        $board AddLine $p2_x1 $p2_y $p2_x2 $p2_y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        $board AddLine $p3_x1 $p3_y $p3_x2 $p3_y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        $board AddLine $p4_x1 $p4_y $p4_x2 $p4_y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        $board AddLine $p5_x1 $p5_y $p5_x2 $p5_y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
        $board AddLine $p6_x1 $p6_y $p6_x2 $p6_y brown 150 "stroke-linecap:round;stroke-opacity:.5;"
    }
    proc row2letter {row} {
        return [format {%c} [expr {$row + 64}]]
    }
}

set b [BPS_BR1 create %AUTO%]
$b WriteFZPZ [$b cget -moduleid].fzpz
#$b WriteBBSVG [$b cget -label].svg

            
