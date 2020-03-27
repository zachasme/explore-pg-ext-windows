CREATE FUNCTION add_one(integer) RETURNS integer
     AS 'h3', 'add_one'
     LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION h3_hex_area(resolution integer, km boolean DEFAULT FALSE) RETURNS float
    AS 'h3' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
    COMMENT ON FUNCTION h3_hex_area(integer, boolean) IS
'Average hexagon area in square (kilo)meters at the given resolution.';
