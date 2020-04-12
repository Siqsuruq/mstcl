set key_words [list LEGEND OUTPUTFORMAT PROJECTION LABEL]
set indent "\t"


proc incr_indent {} {
	set ::indent "$::indent\t"
}

proc dec_indent {} {
	set ::indent [string range $::indent 0 end-1]
}


proc attribute {mapword attr} {
	set prop [string map {= { }} $attr]
	
	if {$mapword eq "IMAGECOLOR" || $mapword eq "OUTLINECOLOR"} {
		puts "$::indent$mapword [dict values $prop]"
	} else {
		puts "\t------------ MAPWORD: \"$mapword\" \"$prop\""
	}
	# elseif {$mapword eq "SIZE" || $mapword eq "KEYSIZE" || $mapword eq "KEYSPACING"} {
		# for {set x 0} {$x<[llength $attr]} {incr x 2} {
			# puts -nonewline " [lindex $attr [expr $x+1]]"
		# }
	# } else {
		# for {set x 0} {$x<[llength $attr]} {incr x 2} {
			# puts -nonewline "\n$::indent [string toupper [lindex $attr $x]] [lindex $attr [expr $x+1]]"
		# }
	# }
}


proc a {args} {
	set mapword [string toupper [lindex $args 0]]
	set attr [lindex $args 2]
	set val [lindex $args 3]
	set a [lsearch -inline $::key_words $mapword]
	
	if {[lindex $args 1] ne "/" && $a ne ""} {
		incr_indent
		if {$attr ne ""} {
			attribute $mapword $attr
		} else {puts "$::indent$mapword $val"}
	} elseif {[lindex $args 1] eq "/" && $a ne ""} {
		set end "END"
		puts "$::indent$end ------------------> $a"
		dec_indent
	} elseif {[lindex $args 1] ne "/" && $a eq ""} {
			if {$attr ne ""} {
				attribute $mapword $attr
			} else {puts "$::indent$mapword $val"}
			# puts "$::indent$mapword $attr $val"
	} elseif {[lindex $args 1] eq "/" && $a eq ""} {
			# puts "$::indent$mapword "
	}
		
}


set xml_file "./mapfile-test.xml"
set doc [dom parse [tdom::xmlReadFile $xml_file]]
set hd "[$doc asHTML]"
::htmlparse::parse -cmd [list a] $hd