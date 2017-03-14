#!/usr/bin/env bash
# export .dot file from Protegee and run this script to visualize as .png with Graphviz
# produces 2 resulting files: a full ontology graph, and a graph with 'Thing' node removed for clearer structure

# Usage:
# > ./run-graph.sh myExampleOntologyGraph.dot

input_dot=$1
output_dot="${input_dot/dot/formatted.dot}"

awk '{gsub(" ([(]Domain>Range[)])|([(]Subclass some[)])","\" color=\"red\" fontcolor=\"red", $0); print $0}' $input_dot > $output_dot

output_png="$output_dot.png"
dot $output_dot -o $output_png -Tpng
#eog -f $output_png


output2_dot="${output_dot/\.dot/.pruned.dot}"
awk '!/owl:Thing/ {print $0}' $output_dot > $output2_dot

output2_png="$output2_dot.png"
dot $output2_dot -o $output2_png -Tpng
eog -f $output2_png

