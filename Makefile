all: build-tests build-main test

.PHONY: build-main

SRC_DIR = pkg
BINS = $(wildcard bin/*)
OBJECTS = $(wildcard obj/*)

# This is all the code with `main` functions in cmd/
MAIN_DIR = cmd
MAINS = $(wildcard $(MAIN_DIR)/*/*.c)

# This is all the files that end with `_test.c` in pkg/
TEST_DIR = pkg
TESTS = $(wildcard $(SRC_DIR)/*/*_test.c)

# All files that are in pkg/ but not tests
SRCS = $(filter-out %_test.c, $(wildcard $(SRC_DIR)/*/*.c))

TESTTARGETS = $(patsubst $(TEST_DIR)/*/%.c,%,$(TESTS))
MAINTARGETS = $(filter-out %_test.c, $(wildcard $(MAIN_DIR)/*/*.c))

UNITYFILES = $(wildcard vendor/unity/*.c)

## build-tests: Builds the test binaries
build-tests: $(SRCS) $(UNITYFILES) $(TESTS)
	$(foreach file, $(TESTTARGETS), $(shell gcc -g -Wall $(file) $(UNITYFILES) $(SRCS)  -o bin$(patsubst %.c,/%.o,$(notdir  $(file)))))

## build-main:  Builds the main programs in cmd/
build-main: $(SRCS) $(MAINTARGETS)
	$(foreach file, $(MAINTARGETS), $(shell gcc -g -Wall $(file) $(SRCS)  -o bin$(patsubst %.c,/%.o,$(notdir  $(file)))))

## clean:       Removes all files in bin/
clean:
	rm -rf bin/*

## test:        Runs the test runner in scripts
test: 
	./scripts/test.sh

## valgrind:    Runs the valgrind runner in scripts
valgrind: 
	./scripts/valgrind.sh

## help:        Show this help.
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'