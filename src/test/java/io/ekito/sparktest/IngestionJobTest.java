package io.ekito.sparktest;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Session;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.DataFrame;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import static io.ekito.sparktest.IngestionJob.loadCSVToDataFrame;
import static io.ekito.sparktest.IngestionJob.storeToCassandra;
import static java.util.stream.StreamSupport.stream;
import static org.junit.Assert.assertEquals;

public class IngestionJobTest {


    private static Session session;

    private static JavaSparkContext sparkContext;


    private static String KEYSPACE = "poc_test";
    private static String TABLE = "us_flights";


    @BeforeClass
    public static void setup() {
        Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build();
        session = cluster.connect();
        SparkConf sparkConf = IngestionJob.sparkConf();
        sparkConf.setMaster("local[8]");
        sparkContext = new JavaSparkContext(sparkConf);
    }

    @Before
    public void init() {
       IngestionJob.createSchema(sparkContext, KEYSPACE, TABLE);
    }

    @After
    public void tearDown() {
        session.execute("drop table " + KEYSPACE + "." + TABLE);
    }


    @Test
    public void shouldLoadCSVToDataFrame() {
        DataFrame dataFrame = loadCSVToDataFrame(sparkContext, "src/test/ressources/USFlightsTest.csv");
        assertEquals(9L, dataFrame.count());
    }

    @Test
    public void shouldStoreDataFrameInDatabase() {
        DataFrame dataFrame = loadCSVToDataFrame(sparkContext, "src/test/ressources/USFlightsTest.csv");

        storeToCassandra(dataFrame, KEYSPACE, TABLE);

        ResultSet result = session.execute("select * from " + KEYSPACE + "." + TABLE);
        assertEquals(9L, stream(result.spliterator(), false).count());
    }
}