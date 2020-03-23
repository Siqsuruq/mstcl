package require nx
package require tdom
package require fileutil
package require chilkat


nx::Class create Mapfile {
	:property name:required
	:property path:required
	
	:method init {} {
		set :map_file [file join ${:path} ${:name}]
		set :tmp_mf [::fileutil::tempfile]
		# Create 3 .xml files
		set :xml_mapfile [::fileutil::tempfile]
		set :xml_layerset [::fileutil::tempfile]
		set :xml_symbolset [::fileutil::tempfile]
		
		if {[file exists ${:map_file}] != 0} {
			puts "EXISTS ${:tmp_mf}"
			set fp [open ${:tmp_mf} a+]
			puts $fp [: -local strip_comments]
			close $fp
		} else {
			puts "EMPTY ${:tmp_mf}"
		}

		# Creating xmlMapFile in memory
		dom createDocument Map :doc
		set :root [${:doc} documentElement]
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
			# Set up initial stack
			set :stack ""
			foreach line $data {
				: -local parse_line $line
			}
			puts [: -local xml]
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
		set keywords [list MAP ANGLE NAME EXTENT SIZE END LAYER STYLE]
		foreach kw $keywords {
			set a [lsearch -inline $line $kw*]
			if {$a != ""} {
				puts "PARSING $line KEY $kw"
				switch  $kw {
					MAP {
						lappend  ${:stack} $kw
						# CkXml_put_Tag ${:root} "Map"
					}
					NAME {
						set work_node [lindex ${:stack} end]
						if {$work_node eq "MAP"} {
							[${:root} getElementsByTagName Map] setAttribute name "[lindex $line 1]"
						}
					}
					LAYER {
						lappend  ${:stack} $kw
						set layer_node [${:doc} createElement Layer]
						${:root} appendChild $layer_node
					}
					EXTENT {
						set extend_node [${:doc} createElement extent]
						$extend_node appendChild [${:doc} createTextNode "[lrange $line 1 end]"]
						${:root} appendChild $extend_node
					}
					ANGLE {
						set angle_node [${:doc} createElement angle]
						$angle_node appendChild [${:doc} createTextNode "[lindex $line 1]"]
						${:root} appendChild $angle_node
					}
					SIZE {
						# CkXml_NewChild2 ${:root} "extent" "[lrange $line 1 end]"
					}
					END {
						
					}
				}
			}
		}
		# puts "$line"		
	} 
	
	:public method "xml" {args} {
		return [${:doc} asXML -xmlDeclaration 1 -encString UTF-8]
	}
}

Mapfile create map -name my_map.map -path ./