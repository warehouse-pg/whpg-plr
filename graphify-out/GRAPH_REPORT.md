# Graph Report - .  (2026-07-28)

## Corpus Check
- Corpus is ~22,975 words - fits in a single context window. You may not need a graph.

## Summary
- 224 nodes · 411 edges · 11 communities (10 shown, 1 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 21 edges (avg confidence: 0.8)
- Token cost: 45,382 input · 0 output

## Community Hubs (Navigation)
- SQL Regression Tests
- PL/R Call Handler Core
- Datum/Array Type Conversion
- Dynamic Library & Hash Cache
- R Environment & Array Utils
- SPI Query Support
- WHPG CMake Build & Rationale
- PG Doc Generation

## God Nodes (most connected - your core abstractions)
1. `r_get_pg()` - 11 edges
2. `coerce_to_char()` - 11 edges
3. `compile_plr_function()` - 11 edges
4. `plr_convertargs()` - 11 edges
5. `do_compile()` - 10 edges
6. `get_scalar_datum()` - 9 edges
7. `pg_scalar_get_r()` - 8 edges
8. `pg_array_get_r()` - 8 edges
9. `pg_datum_array_get_r()` - 8 edges
10. `pg_tuple_get_r_frame()` - 8 edges

## Surprising Connections (you probably didn't know these)
- `compile_plr_function()` --calls--> `plr_HashTableInit()`  [INFERRED]
  plr.c → pg_backend_support.c
- `compile_plr_function()` --calls--> `compute_function_hashkey()`  [INFERRED]
  plr.c → pg_backend_support.c
- `compile_plr_function()` --calls--> `plr_HashTableLookup()`  [INFERRED]
  plr.c → pg_backend_support.c
- `do_compile()` --calls--> `plr_HashTableInsert()`  [INFERRED]
  plr.c → pg_backend_support.c
- `compile_plr_function()` --calls--> `plr_HashTableDelete()`  [INFERRED]
  plr.c → pg_backend_support.c

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **WHPG PL/R Build-Install-Test Pipeline** — whpg_cmakelists_r, whpg_cmakelists_plr, whpg_cmakelists_installcheck, whpg_readme_build, whpg_readme_install, whpg_readme_test [EXTRACTED 1.00]

## Communities (11 total, 1 thin omitted)

### Community 0 - "SQL Regression Tests"
Cohesion: 0.03
Nodes (3): foo, plr_modules, test_data

### Community 1 - "PL/R Call Handler Core"
Cohesion: 0.13
Nodes (29): Node, Datum, FunctionCallInfo, HeapTuple, Oid, PG_FUNCTION_ARGS, plr_func_hashkey, plr_function (+21 more)

### Community 2 - "Datum/Array Type Conversion"
Cohesion: 0.20
Nodes (33): AttInMetadata, attrs, else, MemoryContext, Datum, FmgrInfo, FunctionCallInfo, HeapTuple (+25 more)

### Community 3 - "Dynamic Library & Hash Cache"
Cohesion: 0.17
Nodes (19): Form_pg_proc, FmgrInfo, FunctionCallInfo, Oid, plr_func_hashkey, plr_function, compute_function_hashkey(), expand_dynamic_library_name() (+11 more)

### Community 4 - "R Environment & Array Utils"
Cohesion: 0.28
Nodes (16): ArrayType, Datum, FunctionCallInfo, PG_FUNCTION_ARGS, install_rcmd(), plr_array(), plr_array_accum(), plr_array_create() (+8 more)

### Community 5 - "SPI Query Support"
Cohesion: 0.21
Nodes (12): SEXP, plr_quote_ident(), plr_quote_literal(), plr_SPI_cursor_close(), plr_SPI_cursor_fetch(), plr_SPI_cursor_move(), plr_SPI_cursor_open(), plr_SPI_exec() (+4 more)

### Community 7 - "WHPG CMake Build & Rationale"
Cohesion: 0.21
Nodes (13): Fortran gcc10 FFLAGS workaround rationale (cmplx.f type-mismatch error), installcheck (custom target running PGXS installcheck), R lib symlink rationale (avoid requiring user LD_LIBRARY_PATH changes), plr (ExternalProject_Add target: builds PL/R against built R), plr-whpg CMake Project, r (ExternalProject_Add target: builds R interpreter), R_HOME dual-path rationale (temp build install dir for plr's Makefile vs final GPHOME dir baked into init macro), R_PREFIX design rationale (use /usr/local/greenplum-db as R build prefix) (+5 more)

## Knowledge Gaps
- **4 isolated node(s):** `plr_modules`, `foo`, `test_data`, `StackOverflow: Fortran "type mismatch between two unrelated subroutine calls" (gcc10)`
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `plr_convertargs()` connect `PL/R Call Handler Core` to `Datum/Array Type Conversion`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `do_compile()` connect `PL/R Call Handler Core` to `Dynamic Library & Hash Cache`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `perm_fmgr_info()` connect `Dynamic Library & Hash Cache` to `PL/R Call Handler Core`, `Datum/Array Type Conversion`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `r_get_pg()` (e.g. with `plr_func_handler()` and `plr_trigger_handler()`) actually correct?**
  _`r_get_pg()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `plr_modules`, `foo`, `test_data` to the rest of the system?**
  _4 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `SQL Regression Tests` be split into smaller, more focused modules?**
  _Cohesion score 0.029850746268656716 - nodes in this community are weakly interconnected._
- **Should `PL/R Call Handler Core` be split into smaller, more focused modules?**
  _Cohesion score 0.12605042016806722 - nodes in this community are weakly interconnected._