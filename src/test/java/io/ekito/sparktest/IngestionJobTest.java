package io.ekito.sparktest;


import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Session;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class IngestionJobTest {


    Session session;
    IngestionJob job;


    @Before
    public void init() {
        job = new IngestionJob();
        Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build();
        session = cluster.connect();
        session.execute("create keyspace test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}");
        session.execute("CREATE TABLE test.basket (     \"Id\"         INT PRIMARY KEY,     \"Player\"           text,     \"Number\"        INT )  ;");
    }

    @After
    public void tearDown() {
        session.execute("drop keyspace test");
    }


    @Test
    public void shouldImportCorrectly() {


    }

}
