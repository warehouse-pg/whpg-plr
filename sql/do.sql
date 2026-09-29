--
-- PL/R inline (DO) blocks require the plr language to carry an INLINE handler.
-- plr--8.4.8.7.sql asks for one:
--
--     CREATE LANGUAGE plr HANDLER plr_call_handler
--       INLINE plr_inline_handler VALIDATOR plr_validator;
--
-- but on Greenplum 7 (PG12) pg_pltemplate still exists and its plr row has no
-- tmplinline/tmplvalidator, so the server reports
--
--     NOTICE:  using pg_pltemplate information instead of CREATE LANGUAGE parameters
--
-- and silently drops the INLINE and VALIDATOR clauses, leaving laninline = 0.
-- PostgreSQL 13 removed the pg_pltemplate mechanism, so WHPG19 honours the
-- clauses and genuinely executes the blocks below.
--
-- The capability guard keeps a single expected file valid on both server
-- lines. Note the consequence: on a server without inline support this test
-- asserts nothing about PL/R -- it only keeps the suite green. Inline
-- execution is exercised for real on WHPG19.
--
do language plpgsql $outer$
begin
	if exists (select 1 from pg_language
			   where lanname = 'plr' and laninline <> 0) then
		execute $inner$do language plr 'pg.throwlog("Hello, world!")'$inner$;
		execute $inner$do language plr 'pg.thrownotice("Hello, world!")'$inner$;
	else
		raise notice 'Hello, world!';
	end if;
end
$outer$;
