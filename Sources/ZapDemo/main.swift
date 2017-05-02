import Zap

let zap = Zap()

zap.add(pipeline: .init(plugins: [], formatter: BasicFormatter(), target: ConsoleTarget()))
zap.add(pipeline:.init(plugins: [], formatter: BasicFormatter(), target: FileTarget(filePath: "/Users/muukii/Desktop")))

zap.verbose("test-verbose", 1, 2, 3)
zap.debug("test-debug", 1, 2, 3)
zap.info("test-info", 1, 2, 3)
zap.warn("test-warn", 1, 2, 3)
zap.error("test-error", 1, 2, 3)

zap.verbose("hello")

