import Bulk
import Dispatch

#if os(macOS)

let Log = Logger()

Log.add(pipeline: Pipeline(
  plugins: [],
  targetConfiguration: Pipeline.TargetConfiguration(formatter: OSLogFormatter(), target: OSLogTarget())
  )
)

Log.debug("ABC")
  
#endif
