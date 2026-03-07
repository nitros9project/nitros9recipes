# CoCo 1 Build Recipe

This platform folder contains a CoCo 1 Level 1 recipe.

## Build

```sh
cd coco1
make
```

Primary output:

- `l1_coco1.dsk` (default)

## Notes

- Shared CoCo 1 build logic lives in [`coco1.mak`](coco1.mak) and [`port.mak`](port.mak).
- Per-recipe overrides are in [`recipe.mak`](recipe.mak).
