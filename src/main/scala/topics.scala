package stackoverflow

import org.apache.spark.ml.clustering.LDA

import scala.io.Source
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.SparkSession
import scala.jdk.CollectionConverters._

case class Cluster(clusterId: Int, language_and_weight: List[(String, Double)]){
  def printCluster(): Unit =
  {
    println(s"Cluster $clusterId\n")
    language_and_weight.foreach(pair => println(s"${pair._1},${pair._2}"))
    println("")
  }
}
case class Topic(topic: Int, termIndices: List[Int], termWeights: List[Double])

object Topics extends App {
  if (args.length != 1)
    throw new IllegalArgumentException("Missing required argument for filename.")

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

  println(s"Reading from file '$filename''")

  val sourceFile = Source.fromFile("data/languages.csv")

  // split at 1 to avoid the header
  val languageMap = sourceFile.getLines.splitAt(1)._2
    .foldLeft(Map[Int, String]())(
    (accumMap, line) => {
      val split = line.split(",")

      if (accumMap.contains(split(0).toInt-1))
        accumMap
      else
        accumMap + (split(0).toInt-1 -> split(1))
    }
  )

  val minWeight = 0.05

  val dataset = spark.read
//    .option("numFeatures", (languageMap.size+1).toString)
    .format("libsvm")
    .load(filename)

  println("Training the model...")
  val lda = new LDA().setK(25).setMaxIter(20).setSeed(0L)
  val model = lda.fit(dataset)

  // required for using .as
  import spark.implicits._

  // Describe topics.
  val tpcs = model.describeTopics()
  println("The topics described by their top-weighted terms:")
  tpcs.show(false)


  // Describe topics.
  val topics = model.describeTopics()
    .as[Topic].collectAsList()
    .asScala.toList

  val clusters: List[Cluster] = topics.foldLeft(List[Cluster]()) ((accum, cluster) =>
    {
      cluster match {
        case Topic(topicId, elementIds, weights) =>
          val languageWithWeights = elementIds.zip(weights)
            .filter(_._2 >= minWeight)
            .map(pair => languageMap.get(pair._1) match {
              case Some(languageName) => (pair._1.toString + "-" + languageName, pair._2)
            })
          accum :+ Cluster(topicId, languageWithWeights.sortWith(_._2 > _._2))
        case _ => accum
      }
  })

  clusters.foreach(_.printCluster())
//  println("The topics described by their top-weighted terms:")
//  topics.show(false)

  // Shows the result.
//  val transformed = model.transform(dataset)
//  transformed.show(false)

  val transformed = model.transform(dataset)
  transformed.show(false)
  sourceFile.close()
  sc.stop()


}
