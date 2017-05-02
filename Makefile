build:
	@swift build -c debug -Xswiftc -static-stdlib

gen-xcode:
	@swift package generate-xcodeproj
