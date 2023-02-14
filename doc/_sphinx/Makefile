# Minimal makefile for Sphinx documentation

# You can set these variables from the command line.
# SPHINXOPTS and SPHINXBUILD can also be set from the environment.
SOURCEDIR     = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/..
SPHINXOPTS    ?= -c "${SOURCEDIR}/_sphinx"
SPHINXBUILD   ?= sphinx-build
BUILDDIR      = "${SOURCEDIR}/_build"

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

livehtml:
	sphinx-autobuild $(SOURCEDIR) $(BUILDDIR)/html $(SPHINXOPTS) $(O) --ignore "**/.*" --ignore "*build*" --open-browser

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
