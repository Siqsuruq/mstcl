set key_words [list MAP LEGEND OUTPUTFORMAT PROJECTION LABEL]
set xml_ignore_wrd [list HMSTART CONFIG]
set indent "\t"


proc incr_indent {} {
	set ::indent "$::indent\t"
}

proc dec_indent {} {
	set ::indent [string range $::indent 0 end-1]
}


proc attribute {mapword attr val} {
	set prop [string map {= { }} $attr]
	if {$mapword eq "MAP"} {
		set wrd "MAP"
		puts "$wrd"
		if {[dict exists $prop status]} {
			set wrd "STATUS"
			puts "$::indent$wrd [dict get $prop status]"
		} 
		if {[dict exists $prop name]} {
			set wrd "NAME"
			puts "$::indent$wrd \"[dict get $prop name]\""
		}
		
	} elseif {$mapword eq "IMAGECOLOR" || $mapword eq "OUTLINECOLOR" || $mapword eq "SIZE" || $mapword eq "KEYSIZE" || $mapword eq "KEYSPACING" || $mapword eq "BACKGROUNDCOLOR" || $mapword eq "BACKGROUNDSHADOWCOLOR" || $mapword eq "BACKGROUNDSHADOWSIZE" || $mapword eq "POINT" || $mapword eq "OFFSET" || $mapword eq "SHADOWCOLOR" || $mapword eq "SHADOWSIZE" || $mapword eq "COLOR"} {
		puts "$::indent$mapword [dict values $prop]"
	} elseif {$mapword eq "ITEM"} {
		set wrd CONFIG
		puts "$::indent$wrd \"[dict get $prop name]\" \"$val\""
	} else {
		puts "\t------------ MAPWORD: \"$mapword\" \"$prop\""
	}

}


proc a {args} {
	set mapword [string toupper [lindex $args 0]]
	set attr [lindex $args 2]
	set val [lindex $args 3]
	set a [lsearch -inline $::key_words $mapword]

	# Check ignore words
	if {[lsearch -inline $::xml_ignore_wrd $mapword] eq ""} {
		if {[lindex $args 1] ne "/" && $a ne ""} {
			incr_indent
			if {$attr ne ""} {
				attribute $mapword $attr $val
			} else {puts "$::indent$mapword $val"}
		} elseif {[lindex $args 1] eq "/" && $a ne ""} {
			set end "END"
			puts "$::indent$end ------------------> $a"
			dec_indent
		} elseif {[lindex $args 1] ne "/" && $a eq ""} {
				if {$attr ne ""} {
					attribute $mapword $attr $val
				} else {puts "$::indent$mapword $val"}
				# puts "$::indent$mapword $attr $val"
		} elseif {[lindex $args 1] eq "/" && $a eq ""} {
				# puts "$::indent$mapword "
		}
	}
}


set xml_file "./test_data/mapfile_full.xml"
set doc [dom parse [tdom::xmlReadFile $xml_file]]
set hd "[$doc asHTML]"
::htmlparse::parse -cmd [list a] $hd