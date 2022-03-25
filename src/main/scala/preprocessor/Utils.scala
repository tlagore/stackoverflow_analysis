package preprocessor

object Utils
{
  def timeit(op: => Unit): Long =
  {
    val start = System.currentTimeMillis()
    op
    System.currentTimeMillis() - start
  }
}
