# Contributing

We warmly welcome and greatly appreciate contributions from the
community. By participating you agree to the [code of
conduct](https://github.com/warehouse-pg/whpg-plr/blob/whpg/CODE-OF-CONDUCT.md).
Overall, we follow WHPG's comprehensive contribution policy. Please
refer to it [here](https://github.com/warehouse-pg/warehouse-pg/blob/main/CONTRIBUTING.md)
for details.

## Getting Started

* Fork the `whpg-plr` repository on GitHub
* Clone the forked repository
* Follow the README to set up your environment and run the tests

## Creating a change

* Create your own feature branch (e.g. `git checkout -b
  my_feature_branch`) and make changes on this branch.
* Try and follow similar coding styles as found throughout the code
  base.
* Make commits as logical units for ease of reviewing.
* Rebase with `whpg` often to stay in sync with upstream.
* Add or update tests to cover your code. Set `GPHOME` to your
  WarehousePG installation, build with `cmake ../whpg` and `make` in a
  separate build directory, then run `make install` and
  `make installcheck` against a running WarehousePG cluster. See
  [`whpg/README.md`](whpg/README.md) for build details. Regression
  tests live under [`sql`](sql) and [`expected`](expected).
* Keep changes building on every supported WarehousePG line (6, 7 and
  19), gating version-specific code on `PG_VERSION_NUM`.
* Ensure a well written commit message as explained
  [here](https://chris.beams.io/posts/git-commit/).
* Push your local branch to the fork (e.g. `git push <your_fork>
  my_feature_branch`)

## Syncing with upstream PL/R

The `whpg` branch carries upstream PL/R content without upstream's git
history, so a sync can silently bring back files this fork removes.
Upstream's AppVeyor and Travis CI files are not used here and must be
removed again after every sync:

```
git rm -q --ignore-unmatch appveyor.yml .travis.yml build_script.sh \
    after_build.sh test_script.sh init.sh pggithubbincachefailingfound.sh \
    buildsetup.pl clean_pgsql_sln.sh msvc.diff.R Solution.pm.R \
    server_version_num.sh
```

## Submitting a Pull Request

* Create a [pull request from your
  fork](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).
* Address PR feedback with fixup and/or squash commits:
```
git add .
git commit --fixup <commit SHA>
  -- or --
git commit --squash <commit SHA>
```
* Once approved, before merging into `whpg` squash your fixups with:
```
git rebase -i --autosquash origin/whpg
git push --force-with-lease $USER <my-feature-branch>
```

Your contribution will be analyzed for product fit and engineering
quality prior to merging. Your pull request is much more likely to be
accepted if it is small and focused with a clear message that conveys
the intent of your change.
