BUILD=build
EXECUTABLE=contacts
PREFIX?=/usr/local/bin

.PHONY: build clean install uninstall
SRC=$(wildcard Sources/*.swift)

clean:
	rm -rf $(BUILD)

build: $(SRC)
	mkdir -p $(BUILD)
	swiftc \
		-static-stdlib \
		-O -whole-module-optimization \
		-o $(BUILD)/$(EXECUTABLE) \
		-sdk $(shell xcrun --sdk macosx --show-sdk-path) \
		-target x86_64-macosx10.10 \
		$(SRC)

install: build
	install $(BUILD)/$(EXECUTABLE) $(PREFIX)

uninstall:
	rm "$(PREFIX)/$(EXECUTABLE)"
