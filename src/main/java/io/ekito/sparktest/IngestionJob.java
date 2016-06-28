package io.ekito.sparktest;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Session;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.SQLContext;

import static org.apache.spark.sql.functions.concat_ws;
import static org.apache.spark.sql.functions.col;

public class IngestionJob {

    public static void main(String[] args) {

        String keySpace = "poc";
        String table = "us_flights";

        JavaSparkContext sc = sparkContext();

        createSchema(sc, keySpace, table);

        DataFrame dataFrame = loadCSVToDataFrame(sc);
        dataFrame.printSchema();
        storeToCassandra(dataFrame, keySpace, table);
    }

    static JavaSparkContext sparkContext() {
        SparkConf conf = new SparkConf()
                .setAppName("Data Ingestion job")
                .set("spark.cassandra.connection.host", "127.0.0.1")
                .setMaster("local");

        return new JavaSparkContext(conf);
    }

    static DataFrame loadCSVToDataFrame(JavaSparkContext sc) {
        DataFrame dataFrame = new SQLContext(sc)
                .read()
                .format("com.databricks.spark.csv")
                .option("header", "true")
                .option("inferSchema", "true")
                .load(sc.getLocalProperty("ingestion.csv.file.path"));

        dataFrame = dataFrame.withColumn("Id", concat_ws("-", col("Year"), col("Month"), col("DayofMonth"), col("DepTime"), col("FlightNum")));

        return dataFrame;
    }

    static void storeToCassandra(DataFrame dataFrame, String keySpace, String table) {
        dataFrame
                .write()
                .format("org.apache.spark.sql.cassandra")
                .option("table", table)
                .option("keyspace", keySpace)
                .save();
    }

    static void createSchema(JavaSparkContext sc, String keyspace, String table) {
        String cassandraContactPoint = sc.getConf().get("spark.cassandra.connection.host");
        Cluster cluster = Cluster.builder().addContactPoint(cassandraContactPoint).build();
        Session session = cluster.connect();
        session.execute("create keyspace IF NOT EXISTS " + keyspace + " WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}");
        session.execute("CREATE TABLE IF NOT EXISTS " + keyspace + "." + table + " (\n" +
                "  \"Id\"                text PRIMARY KEY,\n" +
                "  \"Year\"              INT,\n" +
                "  \"Month\"             INT,\n" +
                "  \"DayOfWeek\"         INT,\n" +
                "  \"DayofMonth\"        INT,\n" +
                "  \"DepTime\"           text,\n" +
                "  \"CRSDepTime\"        INT,\n" +
                "  \"ArrTime\"           text,\n" +
                "  \"CRSArrTime\"        INT,\n" +
                "  \"UniqueCarrier\"     text,\n" +
                "  \"FlightNum\"         INT,\n" +
                "  \"TailNum\"           text,\n" +
                "  \"ActualElapsedTime\" text,\n" +
                "  \"CRSElapsedTime\"    INT,\n" +
                "  \"AirTime\"           text,\n" +
                "  \"ArrDelay\"          text,\n" +
                "  \"DepDelay\"          text,\n" +
                "  \"Origin\"            text,\n" +
                "  \"Dest\"              text,\n" +
                "  \"Distance\"          text,\n" +
                "  \"TaxiIn\"            text,\n" +
                "  \"TaxiOut\"           text,\n" +
                "  \"Cancelled\"         INT,\n" +
                "  \"CancellationCode\"  text,\n" +
                "  \"Diverted\"          INT,\n" +
                "  \"CarrierDelay\"      text,\n" +
                "  \"WeatherDelay\"      text,\n" +
                "  \"NASDelay\"          text,\n" +
                "  \"SecurityDelay\"     text,\n" +
                "  \"LateAircraftDelay\" text\n" +
                ")");
    }
}