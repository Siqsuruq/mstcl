package require nx
package require tdom
package require fileutil

nx::Class create Mapfile {
	:property name:required
	:property path
	
	:method init {} {
		if {[info exists :path] != 0} {
			set :map_file [file join ${:path} ${:name}]
		} else {
			set :path ./
			set :map_file [file join ${:path} ${:name}]
		}
		
		set :keywds [dict create Map MAP name NAME end END Layer LAYER Class CLASS Style STYLE angle ANGLE shapePath SHAPEPATH data DATA extent EXTENT size SIZE imageType IMAGETYPE imageColor IMAGECOLOR color COLOR status STATUS type TYPE]
		
		set :tmp_mf [::fileutil::tempfile]
		# Create 3 .xml files
		set :tmp_xml [::fileutil::tempfile]
		
		if {[file exists ${:map_file}] != 0} {
			# puts "EXISTS ${:tmp_mf}"
			set fp [open ${:tmp_mf} a+]
			puts $fp [: -local strip_comments]
			close $fp
		} else {
			# puts "EMPTY ${:tmp_mf}"
		}

		# Creating xmlMapFile in memory
		dom createDocumentNode :doc
		
		# Set up initial stack
		set :stack ""
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
				: -local line $line
			}
			puts "--------------------------------------------------------"
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
	
	:public method "xml" {args} {
		return [${:doc} asXML -xmlDeclaration 1 -encString UTF-8]
	}

	:public method "html" {args} {
		return [${:doc} asHTML]
	}
	
	
	:public method "list_layers" {args} {
		if {[${:doc} hasChildNodes]} {
			set layers_dict [dict create]
			set count 1
			set layers [${:doc} getElementsByTagName Layer]
			foreach lay $layers {
				set line [dict create]
				set attrs [$lay attributeNames]
				foreach attr $attrs {
					dict append line $attr [$lay getAttribute $attr]
				}
				dict append layers_dict Layer$count $line
				incr count
			}
			return $layers_dict
		} else {
			: -local parse
			: -local list_layers
		}
	}
	
	:public method "print_stack" {args} {
		puts "CURRENT STACK: ${:stack}"
	}
	

	# Private classes defenition
	
	:public method "line" {line} {
		set keywords [dict values ${:keywds}]
		foreach kw $keywords {
			set a [lsearch -inline $line $kw*]
			if {$a != ""} {

				switch $kw {
					MAP {
						set node [${:doc} createElement Map]
						${:doc} appendChild $node
						set :stack [lappend :stack $node]
					}
					NAME {
						: -local attr name [lindex $line 1]
					}
					LAYER {
						set work_node [lindex ${:stack} end]
						set node [${:doc} createElement Layer]
						$work_node appendChild $node
						set :stack [lappend :stack $node]
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
					STATUS {
						: -local attr status [lindex $line 1]
					}
					TYPE {
						: -local attr type [lindex $line 1]
					}
					END {
						set :stack [lreplace ${:stack} end end]
					}
				}
			}
		}		
	}
	
	:private method "add_key_val" {key value} {
		set work_node [lindex ${:stack} end]
		set node [${:doc} createElement $key]
		$node appendChild [${:doc} createTextNode $value]
		$work_node appendChild $node
	}
	
	:private method "add_key_attr" {key attrd} {
		set work_node [lindex ${:stack} end]
		set node [${:doc} createElement $key]
		foreach attr [dict keys $attrd] attr_val [dict values $attrd] {
			$node setAttribute $attr $attr_val
		}
		$work_node appendChild $node
	}
	
	:private method "attr" {attr val} {
		set work_node [lindex ${:stack} end]
		$work_node setAttribute $attr "$val"
	}
	
	:public method "parse_xml" {} {
		set root [${:doc} documentElement]
		set :xml_stack [list]
		set :line ""
		
		set tmpxml [open ${:tmp_xml} a+]
		# : -local explore $root $tmpxml
		: -local expl [${:root} asList]
		close $tmpxml

		set fp [open ${:tmp_xml} r]
		set file_data [read $fp]

		close $fp
		puts $file_data
		
	}
	
	:private method "expl" {a} {
		foreach e $ {
			puts $e
		}
	}
	
	
	:private method "explore" {parent tmpxml} {
		set top_tags [list Map Layer Class Style]
		set type [$parent nodeType]
		set name [$parent nodeName]

		puts "$parent is a $type node named $name"
		
		
		if {$type eq "ELEMENT_NODE"} {
			set a [lsearch -inline $top_tags $name]
			if {$a ne ""} {
				set ${:line} [lappend :line [dict get ${:keywds} $name]]
				set :xml_stack [lappend :xml_stack $parent]
				puts "TAG $name NODE $parent"
			}
		} elseif {$type eq "TEXT_NODE"} {
			set ${:line} [lappend :line "[$parent nodeValue]\n"]
		}
		
		# if {$type != "ELEMENT_NODE"} then return

		if {[llength [$parent attributes]]} {
			puts "attributes: [join [$parent attributes] ", "]"
		}
		
		puts $tmpxml ${:line}
		foreach child [$parent childNodes] {
			: -local explore $child $tmpxml
		}
	}
}

Mapfile create map -name my_map.map