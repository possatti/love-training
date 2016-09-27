# Makefile options
SHELL=/bin/bash
.ONESHELL:
.PHONY: all clean

# Other variables
PACKAGE_NAME = 'game.love'
SOURCE_FILES = $(wildcard *.lua) $(wildcard *.png)

run: all
	love $(PACKAGE_NAME)

all: $(PACKAGE_NAME)

$(PACKAGE_NAME): $(SOURCE_FILES)
	zip -r $(PACKAGE_NAME) $(SOURCE_FILES)

clean:
	rm -f $(PACKAGE_NAME)
