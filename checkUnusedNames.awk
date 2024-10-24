#!/bin/awk -f

# Tries to check for words in an awk script used only once, accounting for any language specific keywords or variables.


BEGIN {
	asplit("BEGIN END printf close system atan2 sin cos rand srand match sub gsub ARGC ARGV FNR RSTART RLENGTH SUBSEP do delete function return for if else continue", ignore)
}

# Removing the strings,
/"/ {
	gsub(/"([^"]|\\")*"/, "", $0)
}

# the regex,
/\// {
	gsub(/\/([^\/]|\\\/)+\//, "", $0)
}

# and comments fromt the lines.
/#/ {
	sub(/#.*/, "", $0)
}

# Now checking the cleaned data.
{
	n = split($0, x, "[^A-Za-z0-9_]+") 
	for (i=1; i<=n; i++) {
		if (x[i] in ignore) {
			continue
		} else {
			wordCounts[x[i]]++
		}
	}
}

END {
	for (word in wordCounts) {
		if (wordCounts[word] == 1) {
			printf("%s is only used once in this script. Consider reviewing the script.", word)
		}
	}
}

# Make an associated array from a str
function asplit(str, arr) {
	n = split(str, temp)
	for (i=1;i<=n;i++) {
		arr[temp[i]]++
	}
	return n
}

