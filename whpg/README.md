## Build

```
# Create the build dir
mkdir build
cd build
cmake ../whpg
```

## Install

```
cd build
# You may need root permission if you want to install it to /usr/local/greenplum
make install
```

## Test


```
cd build
make installcheck
```
