package require chilkat

set xml [new_CkXml]
CkXml_LoadXmlFile $xml "mapfile-test.xml"

proc root_childs {xml} {
	for {set i 0} {$i <= [expr [CkXml_get_NumChildren $xml] - 1]} {incr i} {
		#   access the tag and content directly by index:
		puts "[string toupper [CkXml_getChildTagByIndex $xml $i]] [CkXml_getChildContentByIndex $xml $i]"
		# puts [CkXml_get_NumChildren $xml]
		puts  [CkXml_get_version $xml] 
	}
}

proc goxml {xml} {
	set sbState [new_CkStringBuilder]
	while {[expr [CkXml_NextInTraversal2 $xml $sbState] != 0]} {
		puts [string toupper [CkXml_tag $xml]]
		# puts [CkXml_tagPath $xml]
	}
}

proc a {xml} {
	set success [CkXml_FirstChild2 $xml]
	while {[expr $success == 1]} {
		puts "[CkXml_tag $xml] : [CkXml_content $xml]"
		set success [CkXml_NextSibling2 $xml]
	}
	# Revert back up to the parent:
	set success [CkXml_GetParent2 $xml]
}