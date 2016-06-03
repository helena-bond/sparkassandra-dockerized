package io.ekito.sparktest;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.SQLContext;

public class IngestionJob {

    SQLContext sqlContext;

    public IngestionJob() {
        SparkConf conf = new SparkConf()
                .setAppName("Data Ingestion job")
                .set("spark.cassandra.connection.host", "127.0.0.1")
                .setMaster("local");

        JavaSparkContext sc = new JavaSparkContext(conf);
        sqlContext = new SQLContext(sc);
    }

    public DataFrame loadCSVToDataFrame(String filePath) {
        return sqlContext
                .read()
                .format("com.databricks.spark.csv")
                .option("header", "true")
                .option("inferSchema", "true")
                .load(filePath);
    }
}