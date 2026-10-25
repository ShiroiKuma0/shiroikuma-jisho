# isar_community_flutter_libs 3.3.2 — vendored with a patched Android core

This is the pub.dev package `isar_community_flutter_libs` 3.3.2, unchanged
except for the four Android binaries under `android/src/main/jniLibs/`,
which are rebuilt from the isar-community `3.3.2` tag with
`isar-iter-between-stop.patch` applied (`build-libisar.sh` reproduces them).

## The bug

`Cursor::iter_between` in `packages/isar_core/src/mdbx/cursor.rs` walks an
index (or the primary collection) from the lower bound and checks every key
against the upper bound. Past the bound its closure returned `Ok(true)` —
which `Cursor::iter` reads as *continue* — so the walk never stopped: once a
where clause matched anything, every remaining key to the end of the index
was visited and skipped. Results were correct; the cost was proportional to
how much of the index sorts after the key.

In this app that is every dictionary lookup. The `term` index covers ~12
million entries across 65 dictionaries (hundreds of MB), so a kana headword
walked all the kanji headwords after it on every query, and an id
where-clause walked the record store itself. On the phone, which cannot
keep the database in its page cache, that was 1–6 s of reads from flash per
lookup (measured 2026-10-25: a hit cost 90–410 ms of CPU even when cached,
proportional to sort position; a miss cost 0 ms).

The patch stops the walk at the first key past the bound and still reports
`Ok(true)` to the caller, so a query's further where clauses run as before;
only a callback's own `Ok(false)` (e.g. a reached limit) stops a query.

## Updating

When moving to a newer isar_community, check whether `iter_between` is
fixed upstream; if so drop this vendored copy, otherwise re-apply the patch
and rebuild with `build-libisar.sh`. The exported FFI symbols and the
`isar_version()` string (`3.3.2`, checked by the Dart side at open) must
match the Dart package.
