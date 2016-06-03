package io.ekito.sparktest;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Session;
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

    @BeforeClass
    public static void setup() {
        Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build();
        session = cluster.connect();
        sparkContext = IngestionJob.sparkContext();
    }

    @Before
    public void init() {
        session.execute("create keyspace if not exists test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}");
        session.execute("CREATE TABLE if not exists test.basket (\"Id\" INT PRIMARY KEY, \"Player\" text, \"Number\" INT)");
    }

    @After
    public void tearDown() {
        session.execute("drop table test.basket");
    }


    @Test
    public void shouldLoadCSVToDataFrame() {
        DataFrame dataFrame = loadCSVToDataFrame(sparkContext, "src/test/ressources/basket.csv");
        assertEquals(3L, dataFrame.count());
    }

    @Test
    public void shouldStoreDataFrameInDatabase() {
        DataFrame dataFrame = loadCSVToDataFrame(sparkContext, "src/test/ressources/basket.csv");

        storeToCassandra(dataFrame, "test", "basket");

        ResultSet result = session.execute("select * from test.basket");
        assertEquals(3L, stream(result.spliterator(), false).count());
    }
}