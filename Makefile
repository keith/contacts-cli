EXECUTABLE=contacts
PREFIX?=/usr/local/bin
PROJECT=contacts-cli
XCODEBUILD=xcodebuild -project "$(PROJECT).xcodeproj" -scheme "$(PROJECT)"

.PHONY: clean install uninstall

clean:
	xcodebuild clean
	rm -rf build

install:
	$(XCODEBUILD) install DSTROOT=/ INSTALL_PATH="$(PREFIX)"

uninstall:
	rm "$(PREFIX)/$(EXECUTABLE)"
