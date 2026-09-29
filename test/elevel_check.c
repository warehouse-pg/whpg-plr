/*
 * elevel_check.c
 *
 * Proves that the ERROR/WARNING macros plr.h leaves in place are exactly the
 * server's own elevel values, on whichever server line this is compiled
 * against - not merely that plr.h compiles.
 *
 * plr.h #undef's PostgreSQL's ERROR/WARNING around the R headers (a historical
 * name collision) and restores them afterwards. It used to restore them as
 * hardcoded numeric literals, which silently went stale when PostgreSQL
 * inserted a new severity level between them: every ereport(ERROR, ...) in
 * PL/R then reported at a non-throwing level instead of throwing. Against that
 * build this program prints a mismatch and exits non-zero.
 *
 * Build and run (from the repo root, against the server line under test;
 * -O2 keeps unused backend inlines from being emitted, and libpgcommon /
 * libpgport supply the pg_printf that postgres.h redirects printf to):
 *
 *   LIBDIR=$($PG_CONFIG --libdir)
 *   gcc -O2 -o /tmp/elevel_check test/elevel_check.c \
 *       -I. -I"$($PG_CONFIG --includedir-server)" -I"$R_HOME/include" \
 *       $LIBDIR/libpgcommon.a $LIBDIR/libpgport.a -lm
 *   /tmp/elevel_check
 *
 * Exits 0 and prints "ELEVEL CHECK: OK" when the values agree.
 */
#include "postgres.h"

/*
 * The server's real values, captured with no R header in sight. These are
 * whatever elog.h says on this server line.
 */
static const int server_error   = ERROR;
static const int server_warning = WARNING;
static const int server_notice  = NOTICE;

/* plr.h performs the #undef / R-include / restore dance */
#include "plr.h"

/* what every PL/R translation unit actually sees after including plr.h */
static const int plr_error   = ERROR;
static const int plr_warning = WARNING;
static const int plr_notice  = NOTICE;

int
main(void)
{
	int failed = 0;

	printf("server elog.h : ERROR=%d WARNING=%d NOTICE=%d\n",
		   server_error, server_warning, server_notice);
	printf("after plr.h   : ERROR=%d WARNING=%d NOTICE=%d\n",
		   plr_error, plr_warning, plr_notice);

	if (plr_error != server_error)
	{
		printf("MISMATCH: plr.h ERROR=%d but server ERROR=%d\n",
			   plr_error, server_error);
		failed = 1;
	}
	if (plr_warning != server_warning)
	{
		printf("MISMATCH: plr.h WARNING=%d but server WARNING=%d\n",
			   plr_warning, server_warning);
		failed = 1;
	}
	if (plr_notice != server_notice)
	{
		printf("MISMATCH: plr.h NOTICE=%d but server NOTICE=%d\n",
			   plr_notice, server_notice);
		failed = 1;
	}

	/* the property the stale hardcode actually broke */
	if (!(plr_error > plr_warning))
	{
		printf("MISMATCH: ERROR (%d) must outrank WARNING (%d)\n",
			   plr_error, plr_warning);
		failed = 1;
	}

	printf("%s\n", failed ? "ELEVEL CHECK: FAILED" : "ELEVEL CHECK: OK");
	return failed;
}
