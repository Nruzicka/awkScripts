# Removes quotes from the selected csv columns. Add arguments for the program to ignore columns.
# usage: awk -f unquotecsv.awk data.txt col1 col2 col6
# usage (if headers are quoted): awk -f unquotecsv.awk data.txt '"col1"' '"col6"'

BEGIN {
	FS = ","
	OFS = ","
	for (i=2; i<=ARGC; i++) {
		skipHeaders[ARGV[i]]++
		delete ARGV[i]
	}
}

NR == 1 {
	for (i=1; i<=NF; i++) {
		csv[$i] = i
	}
}

{
	parsed = setcsv($0, ",")
	if (parsed) {
		for (header in csv) {
			if (!(header in skipHeaders)) {
				newText = unquote($csv[header])
				$csv[header] = newText
			}
		}
	}
	print($0)
}

function unquote(text,		unquoted) {
	textLength = length(text)
	if (text == "\"\"") {
		unquoted = ""
	} else if (substr(text, 1, 1) == "\"" && substr(text, textLength, 1) == "\"") {
		unquoted = substr(text, 2, textLength-2)
	} else {
		unquoted = text
	}
	return unquoted
}

function setcsv(str, sep,       result) {
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
