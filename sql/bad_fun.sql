-- should error out but should not crash PG
CREATE OR REPLACE
FUNCTION r_bad_fun()
RETURNS int4 AS
$BODY$
  deadbeef <- function(,bad) {}
  42
$BODY$
LANGUAGE plr;

SELECT r_bad_fun();

-- ereport(ERROR) from PL/R must actually THROW, not merely report.
-- plr.h redefines PostgreSQL's ERROR/WARNING macros (a historical collision
-- with R's own headers) and once restored them as hardcoded numeric
-- literals. When a new severity level was inserted between them, every
-- ereport(ERROR, ...) in PL/R silently became a non-throwing client-only
-- report; execution then fell through code that assumed it had aborted and
-- crashed the backend. A throw aborts the transaction, so the statement
-- after it must fail - which a mere report would not cause.
begin;
select r_bad_fun();
select 1 as unreachable;
rollback;
