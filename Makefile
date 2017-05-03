.PHONY: start tests unit-tests integration-tests

start:
	(find . -name '*.ex'; find . -name '*.exs'; find . -name '*.py'; find . -name Makefile) | grep -v '#' | entr -r make tests

tests: 
	./test.py


