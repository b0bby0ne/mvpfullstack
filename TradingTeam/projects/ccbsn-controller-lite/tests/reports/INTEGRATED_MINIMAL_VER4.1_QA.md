# CC Controller M5 Ver4.1 Integrated — QA

Date: 2026-09-07

## Release result

- Status: PASS / official manual Controller-only release.
- Deployment status: not deployed to Real20.
- Package: `releases/cc-controller-m5-ver4.1-integrated-minimal.zip`.
- Package contents: exactly 2 files: Controller EX5 + README.
- ZIP SHA-256:
  `DEF5DC4FDF430E2C215E23F8D70F15E09AFDDF3EC523CD8059633C74FDF862CF`.

## Binary integrity

- Controller MQ5 SHA-256:
  `A2CC4EAF51A16338254A19CC1546607185A64000C85FEDBD8319860D748367FE`.
- Controller EX5 SHA-256:
  `2F96F8BD24712FC94C512EB690185A547D346E1369CFA96A9A025240E9A789E4`.
- CCBSN EX5 SHA-256:
  `F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68`.
- MetaEditor: 0 errors, 0 warnings.

## Static and package QA

- Ver3/Pine parity: 12 checks PASS.
- M5 price gates: 10 checks PASS.
- Policy/state priority: 12 contracts PASS.
- New Cycle lifecycle: 36 contracts PASS.
- Dashboard/checklist: 17 rows PASS.
- Boundary/session: 14 cases PASS.
- Cycle ACK/race: 18 cases PASS.
- AutoTrading resync: 6 cases PASS.
- CSV schema: 64 columns PASS.
- Runtime identity pin: account + exact server PASS.
- Manual OFF pre-seed README contracts: PASS.
- ZIP extraction: exactly 2 files PASS.

## Runtime QA

Direct simultaneous startup was intentionally tested first. Controller sent OFF
ticket `10376546255` and received its ACK, but CCBSN opened a Buy before the
broker-round-trip ACK. This proves that an MT5 EA cannot remove the initial race
when both EAs are restored together.

The final package contains no launcher. The operator must perform the irreducible
two-phase startup manually as documented in README:

1. Start Controller without CCBSN and pre-seed OFF on the broker.
2. Restart with Controller + CCBSN and require the same-ticket ACK.

Internal two-phase runtime QA result before removing the launcher from release:

- Ticket: `10376868313`.
- State: `NC DISABLED` / `ALIGNED`.
- Pending: `NONE`.
- Startup barrier: false.
- Drift: false.
- Identity: valid.
- Integrated runtime guard: true.
- Effective quote digits: 2.
- Positions: 0.
- Entry attempts: 0.
- Cleanup and original-profile restore: PASS.

Evidence:
`tests/runtime-approval/integrated-minimal-full-demo/evidence/20260907-140257/`.

## Production isolation

Post-QA check confirmed Real20 was unchanged: process active, account
`<REAL20_ACCOUNT>`, policy `4.0.0-supervisor`, `NC DISABLED`, `ALIGNED`, pending
`NONE`, startup barrier false and drift false.
