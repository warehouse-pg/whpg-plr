# WarehousePG PL/R

## Introduction

PL/R is a procedural language extension that lets a distributed database like
WarehousePG run functions, aggregates, window functions and triggers written in
R, the language and environment for statistical computing. R code runs inside
the database processes, close to the data, with access to the database through
SPI-based helper functions.

This repository is a fork of the open-source Greenplum PL/R project
(github.com/greenplum-db/plr, no longer public; its history is preserved in the
[`legacy_main`](https://github.com/warehouse-pg/whpg-plr/tree/legacy_main)
branch), renamed to whpg-plr and maintained for WarehousePG. The `whpg` branch
is based on upstream PL/R (https://github.com/postgres-plr/plr), with the
Greenplum changes ported on top.

## Building and Testing

The CMake build in [`whpg`](whpg) downloads and builds R together with PL/R,
so R does not need to be installed beforehand. `GPHOME` must point to your
WarehousePG installation.

```
mkdir build
cd build
cmake ../whpg
make
make install         # may need root to write into $GPHOME
make installcheck    # needs a running WarehousePG cluster
```

See [`whpg/README.md`](whpg/README.md) for details.

## Documentation

* [User guide](userguide.md)
* [Changelog](changelog.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE-OF-CONDUCT.md). To report a security issue, see
[SECURITY.md](SECURITY.md).

## License

GNU General Public License, version 2. See [LICENSE.md](LICENSE.md).

## Credits

PL/R is Copyright (c) 2003 by Joseph E. Conway <mail@joeconway.com>.
It is based on pltcl by Jan Wieck and inspired by REmbeddedPostgres by
Duncan Temple Lang <duncan@research.bell-labs.com>
(http://www.omegahat.org/RSPostgres/).
