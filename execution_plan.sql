
--KEY LOOKUP ==> try to eliminate
/*
1. A key lookup is a lookup against the clustered index
2. The lookup executes once for each row which is so expensive

TO ELIMINATE KEY LOOKUP
a. choose properties on key lookup 
b. copy output list
c. create a non clustered index INCLUDE(OUTPUT LIST COLUMNS) 
*/


--MSSQL JOINS
/*
1. HASH MATCH  ==> efficient for large unsorted data + and used when there is no cluseterd index
    In Query: INNER HASH JOIN
2. NESTED LOOP ==> efficient for small set of data
3. MERGE       ==> efficient for large sorted data + which is joined on index key
*/


--