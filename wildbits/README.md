# Wildbits Build Recipes

## Prerequisites

Set the `NITROS9DIR` environment variable to point to the NitrOS-9 source tree:

```
export NITROS9DIR=/path/to/nitros9
```

Generate the `buildinfo` file (required before first build):

```
cd l1
make buildinfo PLATFORM=jr
```

This creates `$NITROS9DIR/defs/buildinfo` with the current git commit and date info.

## Usage

### Build All (recommended)

From the `wildbits/` directory, build both Level 1 and Level 2 disk images:

```
make all
```

This cleans any existing disk images, then builds both L1 (WildbitsJr) and L2 (WildbitsK2).
Disk images are output to the `disk_images/` directory.

### Build Individually

WildbitsJr for Level 1:

```
cd l1
make PLATFORM=jr
```

WildbitsK2 for Level 2:

```
cd l2
make PLATFORM=k2
```

### Clean

Remove all disk images:

```
make clean
```
