all: lint test

.PHONY: lint
lint:
	shellcheck setup/setup.bash test/ansi-term-test-bash.sh \
		test/test-interactive.sh
	shfmt -l -d -i 4 setup/setup.bash setup/setup.zsh \
		test/ansi-term-test-bash.sh test/ansi-term-test-zsh.sh \
		test/test-interactive.sh

.PHONY: test
test:
	rm -rf dist
	rm -rf emacs.d/elpa/term-alert-1.2
	cask package
	cask install
	cask exec ert-runner
	test/test-interactive.sh

clean:
	rm -rf dist emacs.d .cask *.elc *~ test/*~ setup/*~
