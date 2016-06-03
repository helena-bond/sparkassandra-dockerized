package io.ekito.sparktest;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.SQLContext;

public class IngestionJob {

    protected static JavaSparkContext sparkContext() {
        SparkConf conf = new SparkConf()
                .setAppName("Data Ingestion job")
                .set("spark.cassandra.connection.host", "127.0.0.1")
                .setMaster("local");

        return new JavaSparkContext(conf);
    }

    protected static DataFrame loadCSVToDataFrame(JavaSparkContext sc, String filePath) {
        return new SQLContext(sc)
                .read()
                .format("com.databricks.spark.csv")
                .option("header", "true")
                .option("inferSchema", "true")
                .load(filePath);
    }

    protected static void storeToCassandra(DataFrame dataFrame, String keySpace, String table) {
        dataFrame
                .write()
                .format("org.apache.spark.sql.cassandra")
                .option("table", table)
                .option("keyspace", keySpace)
                .save();
    }
}