package require nx

nx::Class create Mapfile {
	:property name:required
  
	:public method "save" {path} {
		puts "Saving file to: [file join $path ${:name}]"
	}
	
	:public method "parse" {path} {
		set map_file [file join $path ${:name}]
		if {[file exists $map_file] != 0} {
			set fp [open "$map_file" r]
			set file_data [read $fp]
			close $fp
			set data [split $file_data "\n"]
			foreach line $data {
				: -local parse_line $line
			}
		} else {
			return "File doesnt exists."
		}
	}
	
	:public method "strip_comments" {path} {
		set commentChars "#"
		set map_file [file join $path ${:name}]
		set stripped ""
		set fp [open "$map_file" r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		foreach line $data {
			regsub -all -line "\[$commentChars\].*$" $line "" commentStripped
			regsub "^\[ \t]*$" $commentStripped {} fline
			if {$fline ne ""} {
				append stripped "" $fline\n
			}
		}
		return $stripped
	}
	
	:private method "parse_line" {line} {
		set commentChars "#"
		# puts [regsub -all -line "\[$commentChars\].*$" $line ""]
		# regsub -all -line {^[ \t\r]*(.*\S)?[ \t\r]*$} $commentStripped {\1}
		
		# Switch the RE engine into line-respecting mode instead ofthe default whole-string mode
		regsub -all -line "\[$commentChars\].*$" $line "" commentStripped
    # Now strip the whitespace
		puts $commentStripped
		
		
		# set re {[[:blank:]]*#+[[:blank:]]*[[:alnum:]]+}
		# set emp_c {[[:blank:]]*#+}
		# if {[regexp "^$re" $line] != 1 || [regexp "^$emp_c" $line] != 1} {
			# puts "LINE: $line"
		# }
		
	} 
	
}

Mapfile create map -name my_map.map