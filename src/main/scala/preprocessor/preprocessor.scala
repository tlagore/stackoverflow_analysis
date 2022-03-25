package preprocessor

import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.types.{IntegerType, StringType, StructType}
import org.apache.spark.sql.{DataFrame, SparkSession}
import org.apache.spark.{SparkConf, SparkContext}

object preprocessor extends App {
  val rootLogger = Logger.getRootLogger
  rootLogger.setLevel(Level.ERROR)
  Logger.getLogger("org.apache.spark").setLevel(Level.ERROR)
  Logger.getLogger("org.spark-project").setLevel(Level.ERROR)

  val conf: SparkConf = new SparkConf().setMaster("local").setAppName("PreProcessor")
  val sc: SparkContext = new SparkContext(conf)
  val spark = SparkSession.builder()
    .master("local")
    .appName("PreProcessor")
    .getOrCreate()

  sc.setLogLevel("ERROR") // avoid all those messages going on

  val data_dir = args(0)

  val dirFile = new java.io.File(data_dir)
  assert(dirFile.exists(), s"The supplied data directory: '$data_dir' does not exist.")
  assert(dirFile.isDirectory, s"The supplied data directory: '$data_dir' is not a directory")

  println("Reading directory", data_dir)

  val testFiles = dirFile.listFiles.filter(_.isFile)
  testFiles.foreach(f => println(s"Found file ${f}"))
  // remove line below and replace with your code

  val soContext = new StackoverflowContext()

  val postsFile = soContext.readFile(spark, data_dir, SOFile.Posts)
  val tagsFile = soContext.readFile(spark, data_dir, SOFile.Tags)
  val usersFile = soContext.readFile(spark, data_dir, SOFile.Users)
  val languagesFile = soContext.readFile(spark, data_dir, SOFile.Languages)

  postsFile.printSchema()
  tagsFile.printSchema()
  usersFile.printSchema()
  languagesFile.printSchema()

  sc.stop()
}
