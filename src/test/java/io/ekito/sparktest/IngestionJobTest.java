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
        session = cluster.connect("test");
        session.execute("create table ");
    }

    @After
    public void tearDown() {
    }


    @Test
    public void shouldImportCorrectly() {


    }

}
