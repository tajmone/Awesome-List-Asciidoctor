#!/bin/bash
source=index.asciidoc
revdate="$(date --iso-8601)"

# Build a local HTML preview (ignored by Git):
asciidoctor \
	-a IsHTML \
	-a imagesdir=../docs/ \
	-a revdate=$revdate \
	$source
