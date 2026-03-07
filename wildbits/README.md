# Wildbits Build Recipes

This document covers building Wildbits targets from this repository.

## Creating Your Own Recipe (Copy Workflow)

You can clone an existing recipe folder with minimal makefile edits.

Example from `wildbits/`:

```sh
cp -R l1 myrecipe
cp recipe-template.mak myrecipe/recipe.mak
cd myrecipe
make
```

Only edit `myrecipe/recipe.mak` for common customization:

- `RECIPE` to change output name
- `CMDS_EXTRA` to add disk commands
- `BOOTMODS_EXTRA` to add boot modules
- `AFLAGS_EXTRA` / `LFLAGS_EXTRA` for extra flags

This avoids modifying large shared makefiles.

## Prerequisites

From the repository root, ensure:

- `NITROS9DIR` is set to your NitrOS-9 source tree
- toolchain is on `PATH`: `make`, `lwasm`, `lwlink`, `lwar`, `os9`, `zip`

Example:

```sh
export NITROS9DIR=/Users/boisy/Projects/coco-shelf/nitros9
```

## Build Directories

- `l1/` builds Wildbits Level 1 disk images
- `l2/` builds Wildbits Level 2 disk images
- `feu/` builds FEU artifacts (`bootfile`, `booter`, flash packages)

Each build directory keeps intermediate artifacts local:

- `.obj/` object files
- `.lib/` static libraries

## Platform Selection

Supported `PLATFORM` values:

- `k2` (default)
- `jr`

Use as:

```sh
make PLATFORM=jr
make PLATFORM=k2
```

## Level 1 Build (`wildbits/l1`)

```sh
cd l1
make
```

Primary output:

- `l1_wildbitsk2.dsk` (or `l1_wildbitsjr.dsk` when `PLATFORM=jr`)

Useful targets:

- `make all` (same as `make`)
- `make clean`

## Level 2 Build (`wildbits/l2`)

```sh
cd l2
make
```

Primary output:

- `l2_wildbitsk2.dsk` (or `l2_wildbitsjr.dsk` when `PLATFORM=jr`)

Useful targets:

- `make all` (same as `make`)
- `make clean`

## FEU Build (`wildbits/feu`)

```sh
cd feu
make
```

Primary outputs:

- `bootfile`
- `booter`

Additional FEU targets:

- `make booter`
- `make f0.dsk`
- `make f0.zip`
- `make booter.zip`
- `make flash`
- `make upload`
- `make clean`

FEU disk image name pattern:

- `feu_wildbitsk2.dsk` or `feu_wildbitsjr.dsk` (when that target is built)

## Notes

- `startup` in FEU includes a build date line when generated.
- Incremental builds are enabled by dependency tracking in makefiles.

## Troubleshooting

- Missing module/source errors: verify `NITROS9DIR` points to a valid NitrOS-9 checkout.
- `os9` command failures: ensure OS-9 tools are installed and accessible on `PATH`.
- Link errors for Wildbits libraries: run `make clean && make` in the active build directory.
