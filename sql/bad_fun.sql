--
-- A syntactically invalid R body must be rejected, and must not crash the
-- backend. Where the plr language carries a VALIDATOR (WHPG19) that happens at
-- CREATE FUNCTION time; where it does not (Greenplum 7, whose pg_pltemplate
-- plr row has no tmplvalidator -- see sql/do.sql for the detail) the error
-- surfaces on the first call instead. Either way PL/R must raise, not crash,
-- so the assertion is written to hold on both lines.
--
-- Upstream REL8_4_8_7 relies on the validator firing and so expects the error
-- directly from CREATE FUNCTION; that form fails on GP7.
--
do language plpgsql $outer$
begin
	begin
		execute $inner$
			create or replace function r_bad_fun() returns int4 as $body$
			  deadbeef <- function(,bad) {}
			  42
			$body$ language plr
		$inner$;
		-- reached only when there is no validator: force the parse error now
		perform r_bad_fun();
		raise notice 'PL/R did NOT reject the bad function';
	exception when others then
		raise notice 'PL/R rejected the bad function';
	end;
end
$outer$;

--
-- ereport(ERROR) from PL/R must actually THROW, not merely report.
--
-- plr.h redefines PostgreSQL's ERROR/WARNING macros (a historical collision
-- with R's own headers) and once restored them as hardcoded numeric literals.
-- When PG18+ inserted WARNING_CLIENT_ONLY=20 between them, every
-- ereport(ERROR, ...) in PL/R silently became a non-throwing client-only
-- report; execution then fell through code that assumed it had aborted and
-- crashed the backend. plr.h now derives the values from the server headers
-- (and test/elevel_check.c asserts that per line), but this checks the
-- observable behaviour.
--
-- stop() is valid R syntax, so it passes the validator where one exists and
-- raises at runtime on every line. A throw aborts the transaction, so the
-- following statement must fail -- which a mere report would not cause.
--
create or replace function r_runtime_err() returns int4 as 'stop("boom")' language plr;
begin;
select r_runtime_err();
select 1 as unreachable;
rollback;
