package preprocessor

import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.SparkSession
import org.apache.spark.{SparkConf, SparkContext}

class DataFrameHandler(data_dir: String) extends AutoCloseable
{
  val rootLogger = Logger.getRootLogger
  rootLogger.setLevel(Level.ERROR)
  Logger.getLogger("org.apache.spark").setLevel(Level.ERROR)
  Logger.getLogger("org.spark-project").setLevel(Level.ERROR)

  private[this] val conf: SparkConf = new SparkConf().setMaster("local").setAppName("PreProcessor")
  private[this] val sc: SparkContext = new SparkContext(conf)
  private[this] val spark = SparkSession.builder()
    .master("local")
    .appName("PreProcessor")
    .getOrCreate()

  sc.setLogLevel("ERROR") // avoid all those messages going on

  println(s"Loading files from directory $data_dir")

  private[this] val soContext = new StackoverflowContext()
  private[this] val postsDF = soContext.readFile(spark, data_dir, SOFile.Posts)
  private[this] val tagsDF = soContext.readFile(spark, data_dir, SOFile.Tags)
  private[this] val usersDF = soContext.readFile(spark, data_dir, SOFile.Users)
  private[this] val languagesDF = soContext.readFile(spark, data_dir, SOFile.Languages)

  def printSchemas(): Unit =
  {
    postsDF.printSchema()
    tagsDF.printSchema()
    usersDF.printSchema()
    languagesDF.printSchema()
  }

  def close(): Unit =
  {
    sc.stop()
  }

  def parse(): Unit =
  {
    val timeTaken = Utils.timeit {
      postsDF.persist()
      usersDF.persist()
      val query = postsDF.join(right = usersDF, usingColumn = "userid").where("userid == 4089216")
      println("Done")

      print(query.show(10))
      // print(query.collect().mkString("Array(", ", ", ")"))
    }

    println(s"Took ${timeTaken.toFloat/1000} seconds")
  }
}
