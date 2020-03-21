package require nx
package require tdom
package require fileutil


nx::Class create Mapfile {
	:property name:required
	:property path:required
	
	:method init {} {
		set :map_file [file join ${:path} ${:name}]
		set :tmp_mf [::fileutil::tempfile]
		if {[file exists ${:map_file}] != 0} {
			puts "EXISTS ${:tmp_mf}"
			set fp [open ${:tmp_mf} a+]
			puts $fp [: -local strip_comments]
			close $fp
		} else {
			puts "EMPTY ${:tmp_mf}"
		}
	}

	:public method "save" {} {
		puts "Saving file to: [file join ${:path} ${:name}]"
	}
	
	:public method "parse" {} {
		if {[file exists ${:tmp_mf}] != 0} {
			set fp [open "${:tmp_mf}" r]
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
	
	:public method "strip_comments" {} {
		set commentChars "#"
		set stripped ""
		set fp [open "${:map_file}" r]
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
		set keywords [list MAP NAME END LAYER STYLE]
		foreach kw $keywords {
			set a [lsearch -inline $line $kw*]
			if {$a != ""} {puts $line}
		}
		# puts "$line"		
	} 
	
}

Mapfile create map -name my_map.map -path ./