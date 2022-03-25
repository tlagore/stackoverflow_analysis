package preprocessor

import scala.util.Using

object preprocessor extends App {
  if (args.length != 1)
    throw new IllegalArgumentException(s"Improper usage, missing data_directory argument. (Data directory of StackOverflow data files)")

  Using(new DataFrameHandler(args(0)))
  {
      handler => {
        handler.printSchemas()
        handler.parse()
      }
  }
}
