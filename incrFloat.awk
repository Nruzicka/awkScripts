#!/bin/awk -f
# Increments floats by the final decimal point. Increments will never add to the next integer.
# example:  1 -> 2   0.001 -> 0.002   5.99999 -> 5.999991
# usage: awk -f incrFloat.awk 1.999999999999
# usage: echo 1.999999999999 | awk -f incrFloat.awk

BEGIN{
	if(ARGC > 1){
		input = ARGV[1]
		delete ARGV[1]
		newFloat = incrFloat(input)
		print newFloat
		exit
	}
}

{
	newFloat = incrFloat($0)
	print newFloat
}

function incrFloat(x,	formatted){
	incrementer = 1
	precision = 1
	split(x, parts, ".")
	if(length(parts)==2){
		decimal = parts[2]
		for(i=1; i<=length(decimal); i++){
			incrementer = incrementer/10
			precision++
		}
	}
	if((x + incrementer)/(x + incrementer) == 1){
		incrementer = incrementer/10
		precision++
	}
	result = x + incrementer
	format = "%." precision "f"
	formatted = sprintf(format, result)
	sub(/\.?0+$/, "", formatted)
	return formatted
}
