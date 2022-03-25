package preprocessor

import org.apache.spark.sql.{DataFrame, SparkSession}
import org.apache.spark.sql.types.{DateType, IntegerType, StringType, StructType}

import java.io.FileNotFoundException
import java.nio.file.{Files, Paths}

object SOFile extends Enumeration {
  val Posts, Languages, Users, Tags = Value
}

class StackoverflowContext
{
  private[this] val userSchema: StructType = new StructType()
    .add("userid", IntegerType, nullable = false)
    .add("username", StringType, nullable = false)

  private[this] val postsSchema: StructType = new StructType()
    .add("postid", IntegerType, nullable = false)
    .add("posttypeid", IntegerType, nullable = true)
    .add("parentid", IntegerType, nullable = true)
    .add("acceptedid", IntegerType, nullable = true)
    .add("postdate", DateType, nullable = true)
    .add("score", IntegerType, nullable = true)
    .add("postviewcount", IntegerType, nullable = true)
    .add("title", StringType, nullable = true)
    .add("userid", IntegerType, nullable = false)
    .add("answercount", IntegerType, nullable = true)
    .add("commentcount", IntegerType, nullable = true)
    .add("favoritecount", IntegerType, nullable = true)
    .add("postlastactivdate", DateType, nullable = true)

  private[this] val languageSchema: StructType = new StructType()
    .add("languageid", IntegerType, nullable = false)
    .add("language", StringType, nullable = false)

  private[this] val postTagSchema: StructType = new StructType()
    .add("posttagid", IntegerType, nullable = false)
    .add("tag", StringType, nullable = false)

  def getFileContext(file: SOFile.Value): (String, StructType) =
  {
    file match {
      case SOFile.Posts => ("posts.csv", postsSchema)
      case SOFile.Users => ("users.csv", userSchema)
      case SOFile.Tags => ("poststags.csv", postTagSchema)
      case SOFile.Languages => ("languages.csv", languageSchema)
      case _ => throw new IllegalArgumentException(s"file did not match one of ${SOFile.values}")
    }
  }

  def readFile(spark: SparkSession, dataDir: String, file: SOFile.Value): DataFrame = {
    val dataPath = Paths.get(dataDir)

    if (!Files.exists(dataPath) || !Files.isDirectory(dataPath))
      throw new FileNotFoundException(s"Path $dataDir does not exist or is not a directory.")

    val (fileName, schema) = getFileContext(file)

    val filePath = Paths.get(fileName)
    val fullPath = dataPath.resolve(filePath).toAbsolutePath
    
    if (!Files.exists(fullPath))
      throw new FileNotFoundException(s"Could not find $fileName under path $dataPath")

    spark.read
      .options(Map("nullValues"->""))
      .schema(schema)
      .csv(fullPath.toString)
  }
}
