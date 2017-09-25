#!/bin/bash
# export .dot file from Protegee and run this script to visualize as .png with Graphviz
# produces 2 resulting files: a full ontology graph, and a graph with 'Thing' node removed for clearer structure
#
# Usage:
# run-graph FILE [-k]
#       FILE  .dot file exported from Protegee OntoGraph to visualise
#      -k     keep auxiliary files produced during the execution of the script
#
# Example
# $ ./run-graph.sh myExampleOntologyGraph.dot -k

b=$(tput bold)
n=$(tput sgr0)
usage=" Usage:
$b run-graph$n FILE [-k] 
$b	FILE$n	.dot file exported from Protegee OntoGraph to visualise
$b	-k$n	keep auxiliary .dot files produced during the execution of the script
"

if [ -z "$1" ]; then
	printf "$usage"
	exit
fi



input_dot=$1
output_dot="${input_dot/dot/formatted.dot}"

cat <<EOF > program.awk
/Domain/		{next;}
/has individual/	{gsub("has individual","i\" color=\"grey\" shape=\"box\" fontcolor=\"grey", \$0); print \$0; next;}
/has subclass/		{gsub("has subclass","", \$0); print \$0; next;}
			{gsub("([(]Subclass some[)])|([(]Subclass all[)])","\" color=\"red\" fontcolor=\"red", \$0); print \$0}
EOF

awk -f program.awk $input_dot > $output_dot

output_png="$output_dot.png"
dot $output_dot -o $output_png -Tpng

output2_dot="${output_dot/\.dot/.pruned.dot}"
awk '!/owl:Thing/ {print $0}' $output_dot > $output2_dot

output2_png="$output2_dot.png"
dot $output2_dot -o $output2_png -Tpng

if !([ $2 ] && [ $2 == '-k' ]); then
	rm $output_dot
	rm $output_png
	rm $output2_dot
	out="${input_dot/dot/png}"
	mv $output2_png $out
	eog -f $out
	# printf "Graphs produced, auxiliary files removed\n"
fi
