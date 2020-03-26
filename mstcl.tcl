package require nx
package require tdom
package require fileutil
# package require chilkat


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
		dom createDocumentNode :doc
		# set :root [${:doc} documentElement]
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
		# set keywords [list MAP ANGLE NAME SHAPEPATH DATA EXTENT SIZE END LAYER STYLE IMAGETYPE IMAGECOLOR]
		set keywords [list MAP ANGLE NAME LAYER CLASS STYLE SHAPEPATH DATA EXTENT SIZE END STYLE IMAGETYPE IMAGECOLOR COLOR]
		foreach kw $keywords {
			set a [lsearch -inline $line $kw*]
			if {$a != ""} {
				# puts "PARSING $line KEY $kw"
				switch  $kw {
					MAP {
						set node [${:doc} createElement Map]
						${:doc} appendChild $node
						set :stack [lappend :stack $node]
						puts "MAP STACK IS ${:stack}"
					}
					NAME {
						set work_node [lindex ${:stack} end]
						$work_node setAttribute name "[lindex $line 1]"
					}
					LAYER {
						set work_node [lindex ${:stack} end]
						set node [${:doc} createElement Layer]
						$work_node appendChild $node
						set :stack [lappend :stack $node]
							puts "LAYER STACK IS ${:stack}"
					}
					DATA {
						: -local add_key_val data [lindex $line 1]
					}
					EXTENT {
						: -local add_key_val extent [lrange $line 1 end]
					}
					ANGLE {
						: -local add_key_val angle [lindex $line 1]
					}
					SIZE {
						set vals [lrange $line 1 end]
						: -local add_key_attr size [dict create x [lindex $vals 0] y [lindex $vals 1]]
					}
					IMAGETYPE {
						: -local add_key_val imageType [lindex $line 1]
					}
					IMAGECOLOR {
						set vals [lrange $line 1 end]
						: -local add_key_attr imageColor [dict create red [lindex $vals 0] green [lindex $vals 1] blue [lindex $vals 2]]
					}
					COLOR {
						set vals [lrange $line 1 end]
						: -local add_key_attr color [dict create red [lindex $vals 0] green [lindex $vals 1] blue [lindex $vals 2]]
					}
					SHAPEPATH {
						: -local add_key_val shapePath [lindex $line 1]
					}
					STYLE {
						set work_node [lindex ${:stack} end]
						set node [${:doc} createElement Style]
						$work_node appendChild $node
						set :stack [lappend :stack $node]
					}
					CLASS {
						set work_node [lindex ${:stack} end]
						set node [${:doc} createElement Class]
						$work_node appendChild $node
						set :stack [lappend :stack $node]
					}
					END {
						puts "STACK IS ${:stack}"
						set :stack [lreplace ${:stack} end end]

					}
				}
			}
		}
		# puts "$line"		
	} 
	:private method add_key_val {key value} {
		set work_node [lindex ${:stack} end]
		set node [${:doc} createElement $key]
		$node appendChild [${:doc} createTextNode $value]
		$work_node appendChild $node
	}
	
	:private method add_key_attr {key attrd} {
			set work_node [lindex ${:stack} end]
		set node [${:doc} createElement $key]
		foreach attr [dict keys $attrd] attr_val [dict values $attrd] {
			$node setAttribute $attr $attr_val
		}
		$work_node appendChild $node
	}
	
	:public method "xml" {args} {
		return [${:doc} asXML -xmlDeclaration 1 -encString UTF-8]
	}
}

Mapfile create map -name my_map.map -path ./