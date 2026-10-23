-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION plr UPDATE to '8.4.8.7'" to load this file. \quit

-- plr_get_raw() feeds caller-supplied bytes to R's unserialize(), so it is
-- restricted like the other sensitive PL/R helper functions.
REVOKE EXECUTE ON FUNCTION plr_get_raw (bytea) FROM PUBLIC;
