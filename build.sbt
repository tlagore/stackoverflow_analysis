scalaVersion := "2.13.8"

name := "stackoverflow"
scalacOptions ++= Seq("-language:implicitConversions", "-deprecation")

libraryDependencies ++= Seq(
  ("org.apache.spark" %% "spark-core" % "3.2.1"),
  ("org.apache.spark" %% "spark-sql" % "3.2.1"),
  ("org.apache.spark" %% "spark-mllib" % "3.2.1")
)
