package io.ekito.sparktest;


import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Session;
import org.apache.spark.sql.DataFrame;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.stream.StreamSupport;

public class IngestionJobTest {


    Session session;
    IngestionJob job;


    @Before
    public void init() {
        Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build();
        session = cluster.connect();
        session.execute("create keyspace test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}");
        session.execute("CREATE TABLE test.basket (\"Id\" INT PRIMARY KEY, \"Player\" text, \"Number\" INT)");

        job = new IngestionJob();
    }

    @After
    public void tearDown() {
        session.execute("drop keyspace test");
    }


    @Test
    public void shouldLoadCSVToDataFrame() {

        DataFrame dataFrame = job.loadCSVToDataFrame("src/test/ressources/basket.csv");

        Assert.assertEquals(3L, dataFrame.count());

        //ResultSet result = session.execute("select * from test.basket");
        //Assert.assertEquals(3L, StreamSupport.stream(result.spliterator(), false).count());
    }

}