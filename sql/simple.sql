CREATE FUNCTION add_one(integer) RETURNS integer
     AS 'simple', 'add_one'
     LANGUAGE C STRICT;