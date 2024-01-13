EXECUTABLE = contacts
ARCHIVE = $(EXECUTABLE).tar.gz
PREFIX ?= /usr/local/bin

.PHONY: archive clean install uninstall

$(EXECUTABLE):
	swift build --configuration release --arch x86_64 --arch arm64 -Xswiftc -parse-as-library
	cp .build/apple/Products/Release/$(EXECUTABLE) .

install: $(EXECUTABLE)
	install $(EXECUTABLE) $(PREFIX)

uninstall:
	rm "$(PREFIX)/$(EXECUTABLE)"

archive: $(EXECUTABLE)
	tar -pvczf $(ARCHIVE) $(EXECUTABLE)
	@shasum -a 256 $(EXECUTABLE)
	@shasum -a 256 $(ARCHIVE)

clean:
	rm -rf $(ARCHIVE) $(EXECUTABLE) .build
