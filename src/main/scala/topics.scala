package stackoverflow

import org.apache.spark.ml.clustering.LDA

import scala.io.Source
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.SparkSession

object Topics extends App {

  val rootLogger = Logger.getRootLogger()
  rootLogger.setLevel(Level.ERROR)
  Logger.getLogger("org.apache.spark").setLevel(Level.ERROR)
  Logger.getLogger("org.spark-project").setLevel(Level.ERROR)

  val conf: SparkConf = new SparkConf().setMaster("local").setAppName("topics")
  val sc: SparkContext = new SparkContext(conf)
  sc.setLogLevel("ERROR") // avoid all those messages going on
  val spark: SparkSession =
    SparkSession
      .builder()
      .appName("topics")
      .config("spark.master", "local")
      .getOrCreate()

  val filename = args(0)

  // remove line below and replace with your code

  println("Reading from file ", filename)

  // Loads data.
  val dataset = spark.read.format("libsvm")
    .load(filename)

  // Trains a LDA model.
  val lda = new LDA().setK(10).setMaxIter(10)
  val model = lda.fit(dataset)

  val ll = model.logLikelihood(dataset)
  val lp = model.logPerplexity(dataset)
  println(s"The lower bound on the log likelihood of the entire corpus: $ll")
  println(s"The upper bound on perplexity: $lp")

  // Describe topics.
  val topics = model.describeTopics(3)
  println("The topics described by their top-weighted terms:")
  topics.show(false)

  // Shows the result.
  val transformed = model.transform(dataset)
  transformed.show(false)

  sc.stop()


}
