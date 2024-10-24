#!/bin/awk -f

# Demonstrates the csv parser. Pass arguments to filter fields that you wish to print.

BEGIN {
	FS = ","
	OFS = ","
	argsempty = (ARGC <= 2)
	for (i=2; i<=ARGC; i++) {
		filter[ARGV[i]]++
		delete ARGV[i]
	}
}

NR == 1 {
	for (i=1; i<=NF; i++) {
		col[$i] = i
	}
}

{
	result = setcsv($0, ",")

	if (argsempty) {
		print $0
		next
	}

	first = 1
	printfields = ""
	for (c in col) {
		if (c in filter) {
			if (first) {
				printfields = $col[c]
				first = 0
			} else {
				printfields = printfields OFS $col[c]
			}
		}
	}
	print(printfields)
}

## setcsv(str, sep) - parse CSV (MS specification) input.
## str, the string to be parsed (most likely $0).
### sep, the separator between the values.
##
## After a call to setcsv, the parsed fields are found in $1 to $NF.
## setcsv returns 1 on success and 0 on failure.
##
## By Peter Stromberg (aka PEZ).
## Based on setcsv by Adrian Davis. Modified to handle a separator of choice and embedded newlines.
## The basic approach is to take the burden off of the regex matching by replacing
## ambigious characters with characters unlikely to be found in the input. 
## For this, the characters used include ones such as "\035".
## Note, do not call this function with FS as an argument. Hardcode sep instead.

function setcsv(str, sep,	result) {
	FS = SUBSEP
	gsub(/""/, "\035", str)
	gsub(sep, SUBSEP, str)

	while (match(str, /"[^"]*"/)) {
		middle = substr(str, RSTART, RLENGTH)
		gsub(/"/, "\036", middle)
		gsub(SUBSEP, sep, middle)
		str = sprintf("%.*s%s%s", RSTART-1, str, middle, substr(str, RSTART+RLENGTH))
	}

	if (index(str, "\"")) {
		if ((getline) > 0) {
			return setcsv(str (RT != "" ? RT: RS) $0, sep)
		} else {
			return setcsv(str "\"", sep)
		}
	} else {
		gsub(/\035/, "\"\"", str)
		gsub(/\036/, "\"", str)
		$0 = str
		for (i=1; i<=NF; i++) {
			if (match($i, /^"+$/) && length($i) > 2) {
				$i = substr($i, 2)
			}
		}
		$1 = $1 ""
		return 1
	}
}
	

