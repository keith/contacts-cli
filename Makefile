BUILD=build
EXECUTABLE=contacts
PREFIX?=/usr/local/bin

.PHONY: build clean install uninstall
SRC=$(wildcard contacts-cli/*.swift)

clean:
	rm -rf $(BUILD)

build: $(SRC)
	mkdir -p $(BUILD)
	swiftc \
		-o $(BUILD)/$(EXECUTABLE) \
		-sdk $(shell xcrun --sdk macosx --show-sdk-path) \
		-target x86_64-macosx10.10 \
		$(SRC)

install: build
	install $(EXECUTABLE) $(PREFIX)

uninstall:
	rm "$(PREFIX)/$(EXECUTABLE)"
