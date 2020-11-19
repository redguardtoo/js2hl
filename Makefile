SHELL = /bin/sh
EMACS ?= emacs
PROFILER =

.PHONY: test deps

# Delete byte-compiled files etc.
clean:
	@rm -f *~
	@rm -f \#*\#
	@rm -rf deps/
	@rm -f *.elc

deps:
	@mkdir -p deps;
	@if [ ! -f deps/js2-mode.el ]; then curl -L https://raw.githubusercontent.com/mooz/js2-mode/master/js2-mode.el > deps/js2-mode.el; fi;

# Run tests.
test: deps
	$(EMACS) -batch -Q -L deps/ -l deps/js2-mode.el -l js2hl.el -l test/js2hl-test.el
