# WHPG19 tooling spike (parent WHPGN-551)

## Layout — cwd is a container of separate clones, not one git repo

- warehouse-pg-next = WHPG19 source of truth (branch WHPG-master, PG19)
- whpg-backup (+ -s3-plugin, -ddboost-plugin) = gpbackup/gprestore → WHPGN-566
- whpg-dr (+ -integration-test-spike) = whpg-dr → WHPGN-567
- gpload = NOT a repo; lives in warehouse-pg-next (gpMgmt/bin/gpload) → WHPGN-568
- whpg-copy = gpcopy → WHPGN-569
- analytics-llm-product-reference/edb-source-reference-map.md = repo→version/branch map (read first)

## Rules

- Read-only on tool repos. Never docker-build warehouse-pg-next "for everything":
  Go/Python tools don't need it; only tools linking server headers/libs do.
- Build logs → file, then grep error|undefined|fatal. Don't read full logs.
- Reports go to ./reports/<TICKET>-<tool>.md, sections:
  Summary / Build status / Work needed / Complications.
- Never specify yourself as a co-author
## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

Extension changes — always verify via packaging CI

After any fix to an extension repo (whpg-plr, whpg-postgis, whpg-vector, whpg-diskquota, whpg-madlib, whpg-fdw, whpg-pljava, ...), a local build is NOT sufficient evidence. Run the packaging pipeline in EnterpriseDB/whpg-extensions-packaging for both WHPG6 and WHPG7 before calling the work done, and report both results.

Local dev containers are typically aarch64 and build via PGXS. The packaging pipeline builds x86_64 via cmake and then runs make installcheck against a real cluster, so it exercises paths local testing does not. Several classes of bug (multilib lib vs lib64 layout, RPM %files mismatches, GP6-only API differences) are only visible there.

Commands

Push the branch to origin first — the pipeline checks the branch out from the remote, so unpushed commits are not tested.

EXT=plr                       # extension name; workflow is <EXT>-release.yml
BRANCH=my-fix-branch          # branch under test, must exist on origin
PKG=EnterpriseDB/whpg-extensions-packaging

# WHPG7
gh workflow run ${EXT}-release.yml -R $PKG --ref main \
  -f reason="<TICKET>: verify $BRANCH on WHPG7" \
  -f ${EXT}-version=$BRANCH \
  -f whpg-version=7.5.0-WHPG \
  -f maturity=snapshot \
  -f distro=el -f distro-version=9 -f architecture=amd64 \
  -f cloudsmith-upload=false -f enable-tmate=false

# WHPG6
gh workflow run ${EXT}-release.yml -R $PKG --ref main \
  -f reason="<TICKET>: verify $BRANCH on WHPG6" \
  -f ${EXT}-version=$BRANCH \
  -f whpg-version=6.27.5-WHPG \
  -f maturity=snapshot \
  -f distro=el -f distro-version=9 -f architecture=amd64 \
  -f cloudsmith-upload=false -f enable-tmate=false

Get the run id, then check status:

gh run list -R $PKG --workflow=${EXT}-release.yml --limit 2 \
  --json databaseId,status,conclusion,displayTitle \
  -q '.[] | "\(.databaseId) \(.status) \(.conclusion // "-") \(.displayTitle)"'

RUN=<id>
gh run view $RUN -R $PKG --json jobs -q '.jobs[] | "\(.conclusion // .status)\t\(.name)"'

On failure, log to a file and grep it — never read a whole CI log (they are 1–4 MB):

gh run view $RUN -R $PKG --log-failed > /tmp/ci-fail.log 2>&1
grep -inE "fatal error|No such file|RPM build errors|Error [0-9]|::error" /tmp/ci-fail.log \
  | grep -viE '\-Werror=|echo "::error' | tail -20

Rules

- Both server lines, every time. WHPG6 is PG9.4-based and WHPG7 is PG12-based, so they diverge on real APIs. Example: MakeSingleTupleTableSlot takes 1 argument on GP6 and 2 (plus &TTSOpsMinimalTuple) on GP7+. New code needs #if GP_VERSION_NUM >= 70000 guards, matching the surrounding style. Verify an unfamiliar API against the real headers before assuming:
  gh api "repos/warehouse-pg/warehouse-pg/contents/src/include/<path>.h?ref=WHPG_6X_STABLE" -q .content | base64 -d | grep -n "<symbol>"
- <EXT>-version is a git ref, not a version number. It's passed straight to actions/checkout, so a branch or tag both work. whpg-version is what selects the server line.
- cloudsmith-upload=false for every verification run. true publishes the package.
- A green package: job is not a pass. Check smoke:<ext>-el9-amd64 also succeeded — that's the job running make installcheck. If package: fails, smoke: is skipped, so a run can look "mostly green" while no test ever ran.
- -R $PKG is required. Dispatching from inside an extension repo without it targets the wrong repository.
- WHPG19 is not a packaging target, so the pipeline can't validate that line — check it locally against /usr/local/whpg/bin/pg_config.

# General Rules

- **Branching:** Always create a separate branch for each specific task or issue.
- **Local Testing:** Test all changes locally first before pushing anything.
- **Commits:** Do not add yourself (the AI assistant) as a co-author to any git commits.

# Extension changes — always verify via packaging CI

After any fix to an extension repo (whpg-plr, whpg-postgis, whpg-vector, whpg-diskquota, whpg-madlib, whpg-fdw, whpg-pljava, ...), a local build is NOT sufficient evidence. Run the packaging pipeline in EnterpriseDB/whpg-extensions-packaging for both WHPG6 and WHPG7 before calling the work done, and report both results.

Local dev containers are typically aarch64 and build via PGXS. The packaging pipeline builds x86_64 via cmake and then runs make installcheck against a real cluster, so it exercises paths local testing does not. Several classes of bug (multilib lib vs lib64 layout, RPM %files mismatches, GP6-only API differences) are only visible there.

Commands

Push the branch to origin first — the pipeline checks the branch out from the remote, so unpushed commits are not tested.

EXT=plr                       # extension name; workflow is <EXT>-release.yml
BRANCH=my-fix-branch          # branch under test, must exist on origin
PKG=EnterpriseDB/whpg-extensions-packaging

# WHPG7
gh workflow run ${EXT}-release.yml -R $PKG --ref main \
  -f reason="<TICKET>: verify $BRANCH on WHPG7" \
  -f ${EXT}-version=$BRANCH \
  -f whpg-version=7.5.0-WHPG \
  -f maturity=snapshot \
  -f distro=el -f distro-version=9 -f architecture=amd64 \
  -f cloudsmith-upload=false -f enable-tmate=false

# WHPG6
gh workflow run ${EXT}-release.yml -R $PKG --ref main \
  -f reason="<TICKET>: verify $BRANCH on WHPG6" \
  -f ${EXT}-version=$BRANCH \
  -f whpg-version=6.27.5-WHPG \
  -f maturity=snapshot \
  -f distro=el -f distro-version=9 -f architecture=amd64 \
  -f cloudsmith-upload=false -f enable-tmate=false

Get the run id, then check status:

gh run list -R $PKG --workflow=${EXT}-release.yml --limit 2 \
  --json databaseId,status,conclusion,displayTitle \
  -q '.[] | "\(.databaseId) \(.status) \(.conclusion // "-") \(.displayTitle)"'

RUN=<id>
gh run view $RUN -R $PKG --json jobs -q '.jobs[] | "\(.conclusion // .status)\t\(.name)"'

On failure, log to a file and grep it — never read a whole CI log (they are 1–4 MB):

gh run view $RUN -R $PKG --log-failed > /tmp/ci-fail.log 2>&1
grep -inE "fatal error|No such file|RPM build errors|Error [0-9]|::error" /tmp/ci-fail.log \
  | grep -viE '\-Werror=|echo "::error' | tail -20

Rules

- Both server lines, every time. WHPG6 is PG9.4-based and WHPG7 is PG12-based, so they diverge on real APIs. Example: MakeSingleTupleTableSlot takes 1 argument on GP6 and 2 (plus &TTSOpsMinimalTuple) on GP7+. New code needs #if GP_VERSION_NUM >= 70000 guards, matching the surrounding style. Verify an unfamiliar API against the real headers before assuming:
  gh api "repos/warehouse-pg/warehouse-pg/contents/src/include/<path>.h?ref=WHPG_6X_STABLE" -q .content | base64 -d | grep -n "<symbol>"
- <EXT>-version is a git ref, not a version number. It's passed straight to actions/checkout, so a branch or tag both work. whpg-version is what selects the server line.
- cloudsmith-upload=false for every verification run. true publishes the package.
- A green package: job is not a pass. Check smoke:<ext>-el9-amd64 also succeeded — that's the job running make installcheck. If package: fails, smoke: is skipped, so a run can look "mostly green" while no test ever ran.
- -R $PKG is required. Dispatching from inside an extension repo without it targets the wrong repository.
- WHPG19 is not a packaging target, so the pipeline can't validate that line — check it locally against /usr/local/whpg/bin/pg_config.
