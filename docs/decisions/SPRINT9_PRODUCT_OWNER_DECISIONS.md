# Sprint 9 Product Owner Decisions

Approved 2026-08-10 for `OI-016`, the Sprint 9 backup slice of `P4-OI-023`,
and the backup scheduling slice of `P5-OI-008`.

- Backups use a versioned full container containing the encrypted database,
  required managed user files and applicable settings. Rebuildable caches,
  indexes and previews are excluded.
- The container uses AES-256-GCM authenticated encryption with an
  Argon2id-derived backup-passphrase key and Android Storage Access Framework.
- Restore validates and stages the complete archive before atomic replacement.
  Any failure preserves active data. There is no recovery backdoor.
- The latest seven successful automatic backups are retained by default;
  retention is configurable from 1 through 30.
- Manual and exported backups are never automatically pruned. Pruning occurs
  only after a new automatic backup succeeds and never removes the sole valid
  automatic backup.
- Automatic backup uses constrained WorkManager periodic work, daily by
  default with daily or weekly frequency. Exact alarms are excluded.
- Automatic work requires a persisted SAF destination, battery-not-low and
  storage-not-low constraints. Manual backup remains immediately available.

No additional backup policy or Future Release capability is approved here.
