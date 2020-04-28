package require tdom
set fp [open mapfile_simple.xml r]
set fdata [read $fp]

dom parse $fdata doc

set res [dict create]


proc a {node} {
	set attrs [$node attributes]
	if {$attrs ne ""} {
		set attr_dict [dict create]
		foreach attr $attrs {
			dict append attr_dict $attr [$node getAttribute $attr] 
		}
		dict append ::res [$node nodeName] $attr_dict
	}
	
	if {[$node hasChildNodes]} {
		foreach parent [$node childNodes] {
			a $parent
		}
	} else {
		if {[$node nodeType] eq "TEXT_NODE"} {
			dict append ::res [[$node parentNode] nodeName] [$node nodeValue]
		}
	}
}

foreach node [$doc childNodes] {
	a $node
}

puts "---"
puts $res