# friendui-sql

A Clojure library designed to store account information for Clojure Friend in an SQL (JDBC) database.
This is an implementation of the storage protocol in [friend-ui](https://github.com/sveri/friend-ui/) with SQL
(it was tied to Datomic originally).

This library is based on the SQL Korma abstraction layer - a schema file is provided for MySQL/Percona/MariaDB and PostgreSQL.
With the correct parameters (and customized schema), it should also work with Oracle, Microsoft SQL Server,
FirbirdSQL, SQLite3, H2, Vertica and ODBC databases. Pull requests are welcome.


## Usage

`[sventechie/friendui-sql "0.0.2-SNAPSHOT"]`

Currently very rough. Follow [setup instructions for Friend UI](https://github.com/sveri/friend-ui/) and
add a [Korma database spec](https://github.com/korma/Korma):

Load the `schema.sql` file from resources into your database. It creates tables with prefix `azn_`.

```Clojure
   :database {:db "database_name"
             :user "my_username"
             :password "my_password"
             :host "localhost"
             :port "3306"
             :delimiters "`"}
```

This library is not yet available on Clojars, so you'll need to clone the repo and `lein install`.

See [friendui-sql-example](https://github.com/sventechie/friendui-sql-example) for a working example.

## License

Copyright © 2015 Sven Pedersen

Distributed under the Eclipse Public License either version 1.0 or (at
your option) any later version.
