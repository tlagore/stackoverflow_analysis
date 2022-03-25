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
  private[this] val postsFile = soContext.readFile(spark, data_dir, SOFile.Posts)
  private[this] val tagsFile = soContext.readFile(spark, data_dir, SOFile.Tags)
  private[this] val usersFile = soContext.readFile(spark, data_dir, SOFile.Users)
  private[this] val languagesFile = soContext.readFile(spark, data_dir, SOFile.Languages)

  def printSchemas(): Unit =
  {
    postsFile.printSchema()
    tagsFile.printSchema()
    usersFile.printSchema()
    languagesFile.printSchema()
  }

  def close(): Unit =
  {
    sc.stop()
  }
}
