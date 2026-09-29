/* plr--8.3.0.16--8.3.0.18.sql */

-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION plr UPDATE TO '8.3.0.18'" to load this file. \quit

--
-- Bridge script authored for this fork; upstream has no equivalent.
--
-- Upstream's upgrade chain begins at plr--8.3.0.18--8.4.sql, but this fork
-- ships default_version = '8.3.0.16'. Without a step from 8.3.0.16 to
-- 8.3.0.18 an existing install cannot reach 8.4.x at all:
--
--     ALTER EXTENSION plr UPDATE;
--     ERROR:  extension "plr" has no update path from version "8.3.0.16"
--             to version "8.4.8.7"
--
-- It is intentionally empty, because there are no catalog changes to make
-- between those two versions. Verified against upstream history:
--
--   08b67b0 (2016-09-28) "Change version from plr--8.3.0.16 -> plr--8.3.0.17"
--       renamed plr--8.3.0.16.sql to plr--8.3.0.17.sq with zero content
--       change, and touched only the Makefile, plr.control and plr.spec.
--
--   d445325 (2018-10-01) "Update plr.control to reflect new release 8.3.0.18"
--       changed plr.control and nothing else.
--
-- So 8.3.0.16, 8.3.0.17 and 8.3.0.18 are catalog-identical; the two releases
-- were version bumps only. This file exists purely so PostgreSQL can traverse
-- the chain, and must stay empty. Any real change belongs in a later step.
--
