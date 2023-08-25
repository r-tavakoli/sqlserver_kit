

--TO ADD TABLE TO MODEL WITH QUERY YOU NEED CHANGE THE M LANGUAGE SCRIPT TO THIS:

let
    Source = Sql.Database("ServerName", "DbName", [Query="select * from TableName", CreateNavigationProperties=false])
in
    Source

--IF PARTITION HAS ADDED TO TABLE YOU NEED TO CHANGE THE SCRIPT FOR PARTITION AS WELL