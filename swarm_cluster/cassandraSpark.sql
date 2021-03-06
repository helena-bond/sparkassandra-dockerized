create keyspace IF NOT EXISTS sparkassandra WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 2};
CREATE TABLE sparkassandra.us_flights (
  Id                text PRIMARY KEY,
  Year              text,
  Month             text,
  DayOfMonth       text,
  DayOfWeek         text,
  DepTime           text,
  CRSDepTime        text,
  ArrTime           text,
  CRSArrTime        text,
  UniqueCarrier     text,
  FlightNum         text,
  TailNum           text,
  ActualElapsedTime text,
  CRSElapsedTime    text,
  AirTime           text,
  ArrDelay          text,
  DepDelay          text,
  Origin            text,
  Dest              text,
  Distance          text,
  TaxiIn            text,
  TaxiOut           text,
  Cancelled         text,
  CancellationCode  text,
  Diverted          text,
  CarrierDelay      text,
  WeatherDelay      text,
  NASDelay          text,
  SecurityDelay     text,
  LateAircraftDelay text
);
CREATE TABLE sparkassandra.airports (
  iata              text PRIMARY KEY,
  airport           text,
  city              text,
  state             text,
  country           text,
  lat               text,
  long              text
);