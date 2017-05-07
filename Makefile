build:
	@swift build -c debug -Xswiftc -static-stdlib

gen-xcode:
	@swift package generate-xcodeproj

.PHONY: carthage
carthage:
	@carthage build --no-skip-current
