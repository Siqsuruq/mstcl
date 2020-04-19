

proc a {node {ident \t}} {
	set attr [$node attributes]
	set children [$node childNodes]

	if {$children ne ""} {
		foreach child $children {
			if {[$child nodeType] eq "TEXT_NODE"} {
				puts "$ident[string toupper [$node nodeName]] | $attr | [$child nodeValue]"
			} else {
				# puts "$ident[string toupper [$node nodeName]] | $attr"
				a $child "\t\t"
			}
		}
	} else {
		# nodes only with attributes example imagecolr etc.
		puts "$ident[string toupper [$node nodeName]] | $attr | [$node nodeValue]"
	}
}
set node [$root firstChild]
while {[set node [$node nextSibling]] != ""} {
	a $node
}

