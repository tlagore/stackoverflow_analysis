package stackoverflow

import org.apache.log4j.{Level, Logger}
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.ml.fpm.FPGrowth
import org.apache.spark.sql.SparkSession

// lets us convert from java collection to scala
import scala.jdk.CollectionConverters._
//import scala.collection.JavaConverters._

case class FreqMap(freq: Long, items:Array[String]) {
  def compareDesc(that: FreqMap): Int = {
    if (this.freq > that.freq)
      -1
    else if (this.freq < that.freq)
      1
    else
      0
  }
}

object Baskets extends App {
  if (args.length != 1)
    throw new IllegalArgumentException("Missing required argument for filename.")

  val rootLogger = Logger.getRootLogger()
  rootLogger.setLevel(Level.ERROR)
  Logger.getLogger("org.apache.spark").setLevel(Level.ERROR)
  Logger.getLogger("org.spark-project").setLevel(Level.ERROR)

  val conf: SparkConf = new SparkConf().setMaster("local").setAppName("baskets")
  val sc: SparkContext = new SparkContext(conf)
  val session: SparkSession =
    SparkSession
      .builder()
      .appName("baskets")
      .config("spark.master", "local")
      .getOrCreate()

  sc.setLogLevel("ERROR") // avoid all those messages going on

  // allow us to convert to case class
  import session.implicits._

  val filename = args(0)

  println("Reading from file ", filename)
  val basketsRDD = sc.textFile(filename).map(
    _.split(",").toList
  ).toDF("items")

  basketsRDD.foreach(row => if (row(0) == 9634) println(row))

  val fpgrowth = new FPGrowth().setItemsCol("items").setMinSupport(0.02).setMinConfidence(0.5)
  val model = fpgrowth.fit(basketsRDD)

  val output = model.freqItemsets.as[FreqMap]
    .collectAsList()
    .asScala.toList
    .map(el => FreqMap(el.freq, el.items.sortWith(_ < _)))
    .filter(_.items.length > 1)
    .sortWith(_.freq > _.freq)

  output.foreach(item =>
  {
    println(s"${item.freq},${item.items.mkString(",")}")
  })
}
