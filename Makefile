EXECUTABLE = contacts
ARCHIVE = $(EXECUTABLE).tar.gz
PREFIX ?= /usr/local/bin

.PHONY: archive clean install uninstall
SRC=$(wildcard Sources/*.swift)

$(EXECUTABLE): $(SRC)
	swiftc \
		-static-stdlib \
		-O -whole-module-optimization \
		-o $(EXECUTABLE) \
		-sdk $(shell xcrun --sdk macosx --show-sdk-path) \
		-target x86_64-macosx10.10 \
		$(SRC)

install: $(EXECUTABLE)
	install $(EXECUTABLE) $(PREFIX)

uninstall:
	rm "$(PREFIX)/$(EXECUTABLE)"

archive: $(EXECUTABLE)
	tar -pvczf $(ARCHIVE) $(EXECUTABLE)
	@shasum -a 256 $(EXECUTABLE)
	@shasum -a 256 $(ARCHIVE)

clean:
	rm -rf $(ARCHIVE) $(EXECUTABLE)
