# ODD Feature: Rebase P4 Delivery Chain

## Objective

Reconstruct the verified public-portfolio chain on the current `origin/master` without publishing, preserve the reconciled functional history and ordering, and produce clean Feature Branch Chain boundaries for explicit delivery approval.

## Constraints

- Source worktree: `<SOURCE_WORKTREE>`
- Source tip: `d2e9c1c2761cee47ecb8c186c883bc33696512d2`
- Source merge base: `05685e070d0972a47e1bb19f7dd9c9555597570b`
- Target base: `origin/master` at `e9952ed9a268ee7dc4ac328fd7c4aac1ca86dc0b`
- Target branch: `feat/prepare-public-portfolio-reconciled`
- Preserve the two target-base `AGENTS.md` commits.
- Do not push, open or edit pull requests, merge, deploy, or publish.
- Do not transfer prior size exceptions to changed boundaries without explicit maintainer approval.

## Tasks

- [x] ODD-DELIVERY-001 — Replay the 78 source commits onto current `origin/master` in order, resolve only target-base conflicts, preserve functional bytes, and record the old-to-new commit ledger.
- [x] ODD-DELIVERY-002 — Independently verify history completeness, source-byte parity modulo the intended `AGENTS.md` base delta, repository cleanliness, and required runtime gates.
- [x] ODD-DELIVERY-003 — Measure one honest Feature Branch Chain slicing pass, record exact tracker/child boundaries and size exceptions, and stop before publication for explicit maintainer approval.
- [x] ODD-DELIVERY-004 — Defer Firebase Functions registration until a deployable entrypoint exists and close native review of corrected commit `0cb6eda932b7b59a1fff5360bfa48a88ef5a42b7`.
- [ ] ODD-DELIVERY-005 — Preserve the original branch tip, replay all 75 descendants of `a3faf9324e1ca3184ebc2822f4024b187fdc83cd` onto corrected commit `0cb6eda932b7b59a1fff5360bfa48a88ef5a42b7`, resolve only the expected `firebase.json` transition at the accepted provisioning checkpoint, and refresh the replay ledger and delivery boundaries. Route: delegated writer because the history rewrite affects many commits and files.
- [ ] ODD-DELIVERY-006 — Independently verify rewritten history completeness, final tree parity except for the accepted registration timing correction, repository cleanliness, and applicable runtime gates. Route: delegated verifier.
- [ ] ODD-DELIVERY-007 — Resume adaptive native review from the approved corrected window boundary and refresh every affected downstream review window before any delivery decision.

## Current recovery acceptance criteria

- The pre-rewrite branch tip remains reachable through a dedicated local backup ref.
- Rewritten history contains every old descendant in original subject order.
- `firebase.json` omits Functions registration before the real deployable entrypoint and restores it at the accepted provisioning checkpoint.
- Final tracked content differs from the previous final candidate only by the accepted correction and updated ODD evidence.
- No push, pull request, merge, deployment, or publication occurs.

## Evidence

- Native lineage `review-dad9270679ff85a9` approved corrected window `9542895a2451e47ccb3794d513f8563cf9f36e4a..0cb6eda932b7b59a1fff5360bfa48a88ef5a42b7`; exact acknowledgement burned authority. One informational warning at `functions/package.json:8` opened no correction.
- ODD-DELIVERY-005 is blocked before mutation: the package-owned writer and its single explicitly authorized remediation retry both refused local ref creation, history rewriting, staging, and commits. No backup ref, stash, rebase, or commit was created; branch tip remains `6b95978162a9c0debce04e98c96d1d4a91fb1675`.
- Project-local Git-history executor candidate: `.pi/subagents/git-history-worker.md`, `.pi/extensions/git-history.ts`, `.pi/agent-tests/git-history.test.ts`, and `.pi/agent-tests/git-history.integration.test.ts` remain untracked here. `start` now requires a direct RPC `ctx.ui.confirm` of the exact plan within the same invocation, fresh preflight afterward, a local/worktree Git-config allowlist, and a backup before rebase; it never auto-resolves conflicts. Independent verification observed 11/11 mocked and 4/4 disposable real-Git tests pass, including a linked worktree. The HEAD-drift case is mocked, not proven with real Git. Pi lists `git-history-worker` as a project agent; its task-mode session confirmed `git_history` exposure without invoking it. A separate Pi RPC child emitted the exact `Authorize local Git history rewrite` confirmation for `<DISPOSABLE_RPC_REPOSITORY>`. The first fixture timed out before consuming the human answer and left HEAD and refs unchanged. On the single fresh-dialog retry, the maintainer approved only the disposable plan: `backup/work` retained old tip `8a3ff03e77f13f700cfd1ed69199ef8a8882a15a`, and the disposable feature tip became `dbc71bf361671e94c11ddc43dcc9d3c9ad2a5565` with parent `0f8c68c3b8758071a00f90efb6dd3b4162a0c6cd`. Independent verification confirmed clean disposable status and both feature/onto files. The real branch remains `6b95978162a9c0debce04e98c96d1d4a91fb1675` with this task document modified and `.pi/` untracked, so its required clean-tree preflight still blocks real history rewriting. Do not rewrite real history until that gate and a new exact-plan approval pass. Native risk assessment for this untracked candidate was unavailable (`untracked files require an explicit declaration`); no native review outcome is claimed.

## Delivery plan (ODD-DELIVERY-003)

The maintainer explicitly accepted this exact topology and exactly these 16 fresh `size:exception` totals: 854, 733, 490, 3100, 3687, 2180, 612, 14036, 461, 523, 639, 545, 1783, 593, 2065, 7635. Tracker `feat/portfolio-delivery-tracker` is proposed for later creation at exact base `e9952ed9a268ee7dc4ac328fd7c4aac1ca86dc0b`, which yields a zero diff; the ref does not exist yet, as required by the pre-publication stop. The Feature Branch Chain has 36 cumulative children. Aggregate `origin/master..6fc919f`: 30,623 additions / 11,004 deletions / 41,627 lines. The final two ODD evidence commits remain in child 36. Live GitHub Actions remains pending delivery. Approval closes local planning only; it does not authorize push, PR creation, merge, deploy, or publication.

Each inclusive replay range is measured against the preceding row's last commit (row 1 against `origin/master`). Additions/deletions use local Git numstat; the binary Gradle wrapper contributes no line counts.

| Position | Branch | Inclusive replay range | Additions | Deletions | Total | Fresh exception |
| ---: | --- | --- | ---: | ---: | ---: | --- |
| 01 | `feat/chain-bootstrap-format` | `c6f96c0..74da290` | 732 | 122 | 854 | `size:exception` |
| 02 | `feat/remove-status-artifact` | `c519885..c519885` | 0 | 114 | 114 | — |
| 03 | `feat/migrate-portfolio-openspec` | `4aab9ac..4aab9ac` | 733 | 0 | 733 | `size:exception` |
| 04 | `feat/remove-demo-credentials` | `88c6ee5..88c6ee5` | 273 | 217 | 490 | `size:exception` |
| 05 | `feat/clarify-deployment-status` | `9542895..9542895` | 112 | 3 | 115 | — |
| 06 | `feat/functions-dependency-scaffold` | `a3faf93..a3faf93` | 3099 | 1 | 3100 | `size:exception` |
| 07 | `feat/provisioning-contract-model` | `8723f09..15632a7` | 3583 | 104 | 3687 | `size:exception` |
| 08 | `feat/validated-provisioning-constructors` | `fd3bca2..55ad4c9` | 2071 | 109 | 2180 | `size:exception` |
| 09 | `feat/cas-reducer-lease-contract` | `8e0831a..9f41787` | 494 | 118 | 612 | `size:exception` |
| 10 | `feat/portfolio-baseline-reconciliation` | `40afe83..d6336ec` | 114 | 0 | 114 | — |
| 11 | `feat/outbox-race-coverage` | `690c527..7fe44bc` | 191 | 3 | 194 | — |
| 12 | `feat/retry-conformance-coverage` | `07ea165..f5bec0b` | 141 | 2 | 143 | — |
| 13 | `feat/accepted-provisioning-checkpoint` | `f31d1c8..13a90b7` | 13599 | 437 | 14036 | `size:exception` |
| 14 | `feat/crash-reconstruction-coverage` | `bb5d430..2acd503` | 243 | 2 | 245 | — |
| 15 | `feat/terminal-concurrency` | `605d500..494f86c` | 342 | 119 | 461 | `size:exception` |
| 16 | `feat/freeze-p3-backend` | `57e01e3..4f7bc1c` | 281 | 60 | 341 | — |
| 17 | `feat/trusted-callable-transport` | `185fb89..185fb89` | 231 | 36 | 267 | — |
| 18 | `feat/p4-flutter-compatibility` | `3a38f35..bbc26fc` | 90 | 18 | 108 | — |
| 19 | `feat/reconciled-chain-preparation` | `ea6c0a0..1a1c71e` | 79 | 71 | 150 | — |
| 20 | `feat/early-gate-stabilization` | `d1b6791..e52c4b0` | 110 | 57 | 167 | — |
| 21 | `feat/portable-staged-formatter` | `f8856a3..f8856a3` | 273 | 250 | 523 | `size:exception` |
| 22 | `feat/callable-contract-mapping` | `d43be5c..a55fba4` | 635 | 4 | 639 | `size:exception` |
| 23 | `feat/resilient-status-polling` | `a450bd2..a450bd2` | 545 | 0 | 545 | `size:exception` |
| 24 | `feat/employee-creation-ux` | `1905d99..1905d99` | 765 | 1018 | 1783 | `size:exception` |
| 25 | `feat/retire-direct-client-creation` | `2f94fe3..2f94fe3` | 55 | 538 | 593 | `size:exception` |
| 26 | `feat/firestore-user-write-hardening` | `897eee6..897eee6` | 1936 | 129 | 2065 | `size:exception` |
| 27 | `feat/p4-final-gate-checkpoint` | `e93afbb..c2b9094` | 112 | 67 | 179 | — |
| 28 | `feat/wu5-toolchain-transition` | `4edb048..28db35f` | 345 | 40 | 385 | — |
| 29 | `feat/visible-app-branding` | `5645af0..f62dea3` | 129 | 25 | 154 | — |
| 30 | `feat/repository-sanitizer` | `296f06a..296f06a` | 245 | 0 | 245 | — |
| 31 | `feat/sanitize-portfolio-configuration` | `2797948..1981fd8` | 84 | 108 | 192 | — |
| 32 | `feat/portfolio-quickstart` | `367400c..367400c` | 77 | 208 | 285 | — |
| 33 | `feat/retire-deployment-claims` | `d80f84b..634763e` | 11 | 387 | 398 | — |
| 34 | `feat/portfolio-readme` | `605c186..e272a35` | 25 | 326 | 351 | — |
| 35 | `feat/remove-archived-history` | `041e490..9daca25` | 2 | 7633 | 7635 | `size:exception` |
| 36 | `feat/final-portfolio-ci-and-closure` | `b3f3dc6..6fc919f` | 213 | 25 | 238 | — |

ODD-DELIVERY-001 replay evidence (documentation only; independent verification and runtime gates remain ODD-DELIVERY-002):

- Source merge base: `05685e070d0972a47e1bb19f7dd9c9555597570b`; source tip: `d2e9c1c2761cee47ecb8c186c883bc33696512d2`.
- Target base (`origin/master`): `e9952ed9a268ee7dc4ac328fd7c4aac1ca86dc0b`; plan commit: `c6f96c00c3b8446529fe6968ad15b80839052e28`; replay tip: `91f6e2d847ca00fc4321338abb89d3da86aa7bec`.
- Replay reported no conflicts. Local Git history confirms 78 source and 78 replay commits with identical ordinal subject order.
- Tip tree diff is limited to `AGENTS.md` and this task file; all other tracked tree bytes match. Replay-tip `AGENTS.md` blob equals `origin/master:AGENTS.md` (`cea78f8423e1b64c9ae2cab0b492093e9f91000b`).

ODD-DELIVERY-002 independent verification evidence:

- Toolchain: Flutter 3.47.5 / Dart 3.13.4 and Temurin 21.0.12.1. Initial `flutter pub get` succeeded; its incidental `analysis_options.yaml` drift was restored under explicit maintainer authorization, and subsequent Flutter commands used `--no-pub`.
- Formatting: 273 files checked, 0 changed. The sanitizer initially failed only because this new task document contained an absolute user-machine path; replacing it with `<SOURCE_WORKTREE>` produced a corrective sanitizer PASS. Analyzer PASS; Flutter tests 616/616 PASS.
- Debug APK PASS (170,268,183 bytes); web release PASS. Functions: 273 tests total, 237 passed / 36 skipped; TypeScript build PASS. Firestore rules: 64/64 PASS.
- Release build failed closed as expected because `release-signing.properties` was missing. Source/replay parity and diff-check PASS. Untracked generated `android/build` and `functions/lib` were removed under explicit maintainer authorization; ignored reproducible outputs remain local. Independent corrective verification PASS.

| # | Source commit | Replay commit |
| ---: | --- | --- |
| 01 | `491541958865cb37fa128c6632ef70823d00fa6e` | `dd2020ad59e00a3a7e147e4f97ba3f2f228a92b7` |
| 02 | `3e9146f1895bad5da49a5553812afd41e5153ece` | `74da2905faa37b11bfd8db96dee1041dbcbdbf6d` |
| 03 | `7772e14e1b957692ba1744b3120913e5e8f9ddc9` | `c519885bc4991183cd26965e415290770efc85bc` |
| 04 | `5f7eb3a24f1aa36aaf1d66a8f0a13789bbeb0a32` | `4aab9ac66e9e303c9dd2c9b60d7ad7f7e77e5bb9` |
| 05 | `b5eec2f3475fe26b0eab1c4887efc9e86a4f7ed2` | `88c6ee50a0199426ec3f512ebc99792c6e134ae4` |
| 06 | `ea22d2280b7b0e15f3fd4c5b8bb8c9b7d6a7ff54` | `9542895a2451e47ccb3794d513f8563cf9f36e4a` |
| 07 | `a0a79cc2de3bf0fa8178ead4badfe0d1880b1629` | `a3faf9324e1ca3184ebc2822f4024b187fdc83cd` |
| 08 | `c9ab63a3e098de53ccd0e0ed8e2abf9017e3eed3` | `8723f09f96bacda3440aac2cc659f6d13c32895e` |
| 09 | `f67c880d173f8342128797cf095b8059352755fa` | `8a5c7f60a718e97861c876b0bdfcdaf348b45bf2` |
| 10 | `1c8ce4f0249fe8eaa1c8ed22115e15136de57a48` | `10c6a2c8ca57bdf87832572b28136185896cc0ea` |
| 11 | `5904fc8797087203b83c911912114243e4d53a69` | `2200c9e34ba54d36bc961afce42b147424feaf62` |
| 12 | `91679299e3f60f88eb2d741ce9824260e96e9e24` | `15632a76124b382b143bad2d78d4b219506b1571` |
| 13 | `5779e88df5e20686ecceed06dc7654480ffe9a03` | `fd3bca2a08aef25f21dc069f0b8af082660a1b32` |
| 14 | `860f3c39649113acab124a489e6fa99ff35d9c5c` | `7951ed7b772b5ba31d430979aaae6b116212dc61` |
| 15 | `b86f98853e5d048355fe33281bced265ad6ea580` | `3954772ba99a6014b7ca7b6cb66fbdc150c4cdf9` |
| 16 | `f8ac32f07dd3398a7d9f7c6df82d4947591543cb` | `5c2a92ac074aa26be585d5121434511f7950b6a6` |
| 17 | `80cf6bc4ccd53ebb670d5577c3c6a8ef5d86fce9` | `55ad4c9db63c08f0006bbf1de962092afb794bce` |
| 18 | `8f0867e2ba77ac3d97cb789200ac9c85d0d10705` | `8e0831af48af216b867210166d78bdd903c1337d` |
| 19 | `306fb0d931c0d877e79fd203d3397e05302b68b8` | `d3dc4f51eccb28b8aa84dad103acf92c8621f658` |
| 20 | `76bd104b44a46aa9c530eb7e90d4596dedaaf592` | `9f4178700da0e0e4e8543cffedc8ba598223c58d` |
| 21 | `bc781d246ac566f3adea95cc9ed3d8d3cdba7e44` | `40afe83da941a88f69a2b858a26cb163610ab55d` |
| 22 | `0a84f0580f1cca45e2b48767341790ed2fd0b82c` | `8c707ec112c1d0f796f299e99b89878f9e6e16b5` |
| 23 | `cdaf4f908428d595243d25c49a0f87317ceba6d0` | `5fbffb44f8d1eb142340e82fa804873169bc98a3` |
| 24 | `af77e5cec078ede395660a8b92b4fb47cf19fccf` | `d6336ec530611448fba0c91e8308a148a657b030` |
| 25 | `7cf7f077f57932b46a0b33811194a49ff07fc202` | `690c5277a961e9fdfb9365cf6563ce5eae4cb480` |
| 26 | `883a56f7223c1c4449095fb765c7cd36d78e63ff` | `7fe44bc1a548a9dc11aeeb422091c68ec124a834` |
| 27 | `e3c1bf30048d90b417b27861607a8b159b750739` | `07ea16525b00ff86e1c214857b12161620973480` |
| 28 | `8e84f253e7ad5ddf39bec605be43bdcf1eb8f730` | `f5bec0b0dd5b02fd6364be3ab775a717d4e54c8d` |
| 29 | `7b5c687a48a38cb7b7c3d1d8fca4532a43d6ddf1` | `f31d1c80ba7ca0d20beba0c267665574c48baa55` |
| 30 | `fcfcbc885b0cae4f1679f3aa584b240f81956d14` | `13a90b7dfee2007b046f7e346cb0615b45791ddf` |
| 31 | `3cbca8a1659d1573c4cd75460aecb71ed262aac4` | `bb5d4308b1a03096452e09cbc51ea6166ac60105` |
| 32 | `8a7263fde353a53f0ca4b36ae4eb38430945ff0c` | `2acd50399a3521adbfde0ecb62d3b5bc7c85f8f5` |
| 33 | `bf42482f34672cb0c06035764ced9b709a69f8a7` | `605d500ae204c693d311c604a8b2eadd2d3df296` |
| 34 | `051b769e06b432a64ba836db881c33c5f8f7ad95` | `494f86c0852c8a4c05808b2a75b627b5da4dda49` |
| 35 | `348aafb1a29ed9eae6cc4f066bbdb3e2853708d1` | `57e01e3575dfd6e65ad31c188cff6616a0adaa6a` |
| 36 | `043071812cc112da5c4bd24d951b7d2a89e84605` | `4f7bc1cbe7a160bad4e9755e8d03c08569ebedc3` |
| 37 | `276ad35dd3b297fee0a67d5c5c82467bc1137f10` | `185fb89b513a1373dfc88a1be6e9336db006ac4c` |
| 38 | `ba33e29e2fa2d9e5df85c4ca7f659aa52a7c2eb7` | `3a38f35caca992430ad2e27c3cc8176881fb7db3` |
| 39 | `00b4afae04c015f05f7f4fbf4b47d2a4c018a9f1` | `bbc26fc3c36754953d21430d9aa485b71f22ab4e` |
| 40 | `6167e67f0ba98d2d0cb8239900e8cb2d26fc6a28` | `ea6c0a02010ec98b27864ed74dc4071d030513af` |
| 41 | `d79f6c34bb9a5b8aaaafac124ef4b2c0882982ab` | `1a1c71ebe0f4b24828931e882960d4a5ca4cb7fd` |
| 42 | `7de3d1e699d1ef0860ef1d783d202e1bf5e26fee` | `d1b6791dcc34b918d9395ffd3975dd1abc5aa9c5` |
| 43 | `223553de5b0a6108ff38b3153e2a88c42e0aed95` | `e52c4b04af2ed4441bf83af1532133185d3a2f1c` |
| 44 | `12250760867b47fd59ef6cee7345b183a69abfc9` | `f8856a31e9b3bc35fb55f6dc6782d28b5ed907a5` |
| 45 | `0ea514e6f251751ba46acc6213e7ca0f0726db92` | `d43be5c27a85372c6ad5f86133da6c67fe0467ff` |
| 46 | `e6b958bc8ff611177b23af1c0941e4a5453ab848` | `a55fba45f1e579a637c46e53f1f6e15242df82d4` |
| 47 | `2338c1d01a91b718c0b9c16c5e894e8aea0aa164` | `a450bd28bb08f58dad0ea02af529afefb628fe88` |
| 48 | `e458dead1e67d6ff03ece0dc4e0d3e3794b28cdf` | `1905d993f284f318d5f94e3dd177c60b89a95452` |
| 49 | `d29e9e6680981654f845b84ee17dc03ba5663f40` | `2f94fe308d07c1a2a0fa1240a08b2cbf7076ff1c` |
| 50 | `1bd4ac8539169d36b34dbc47a93c45c06653374c` | `897eee689e77bdf7f77681ca6111c57231c152d2` |
| 51 | `17fcf2604864544009d28254e103e8c3804083bd` | `e93afbba348742db4371bb2de5394a6b85a117bc` |
| 52 | `ab14a59b18ac6bc39775fb6be939a907fd8c7318` | `99c5be7fbd587a1c7f273b8cf1e01a81e53311ac` |
| 53 | `98d140f59e4816a584c3f94545ea9e74a77f93a5` | `3699a21da9fd105aa42887399a3daa0c5fd1de16` |
| 54 | `1cfec23d0433e6258c9f76c2f24a08b5f86c2169` | `c2b9094b99f7aeb4abf00277b6118dbfa88230cd` |
| 55 | `8794ea6a4a90c8003ba8f29ea8e2c3897f9416b5` | `4edb048152521f5d9508c72bc425c1933f5c3f9b` |
| 56 | `e04e741576fe8c7fd5309c7872ca5e9f56f4f95d` | `ac7bb3568b115d4e5b1ef8b3a034c2d9d8c6d949` |
| 57 | `5132b4ad7dfe531d603ff793f4dc17361804aef2` | `72455052c8b0fcb8c6ad7b44437ef573ffa7abb4` |
| 58 | `7b0263bc9b116242ef8e14e6efa03b0889b23125` | `2694f91aa62b266292359238d275bfaf92800ade` |
| 59 | `b2871499ac58f9cf358aeface0c727e4367be860` | `28db35fd65ccbe2a4df60025f2fe382ea96da5d8` |
| 60 | `4950632eac8d421c51c1814d7fde5f08990942ea` | `5645af09fc18de39173f2a0dd641ae99ce358f28` |
| 61 | `873aac25d14dca3ace3416cd88b594f188ce6173` | `d7e964ccb2aeeaf687eb8a696d95329ed5208173` |
| 62 | `b179389cb7c0802e84a2af40da5a2def36ad83d8` | `f62dea3ee284567965c396503508046c5320054c` |
| 63 | `47c44931bb5764811d97ac38a810d6d489af826f` | `296f06a17a426e08e5b82a32d366e5a98271cbe8` |
| 64 | `81daac88b3144429c463acadba9b98dada137c36` | `2797948c0dbb83b67d235646e08242e7e4d65a86` |
| 65 | `ff90fad7c7d888e587a286adb107eba7f54ea781` | `1981fd8adf50580843466361b7cdd0f40bc0ca2e` |
| 66 | `29b2655662e69bbe4469d69446023c3045d4169f` | `367400cc285d548bc038b4a5543ba48cc51fe1f7` |
| 67 | `514c2e4f5a4628714d920a4cbbccf8be17fe7853` | `d80f84b9da1efd6c51feb6fc2b4978a4e6908bce` |
| 68 | `10190bc08cdb06ed809b98a65101b98631d35362` | `634763e0275e3493e9623b972faa2db4452c4168` |
| 69 | `f5abdd60c4bac11cb9b6c708a6c9710d45cdedb3` | `605c18622377b9472872ced200212da27f5e3e03` |
| 70 | `1fa28aa5906b185834f68df4d6eb0455be97b3c7` | `e272a3518fab9260c005e29360dbcd2f0f674d16` |
| 71 | `b10fa2750724dfc696099f25f0044f3abecdeb1c` | `041e490e33f7fc0e8af78ab3d3890ce3be92b7b1` |
| 72 | `ee9cdf6f7d97aee6c49b1f4c4f07160638c5b4ee` | `9daca252d92554eadccca2f2ebb9bfdf032776ea` |
| 73 | `5d3255c1829f096c83d3833ea67b653e3429eeac` | `b3f3dc604ca458dc23624b5a930ab8fa5a961a78` |
| 74 | `37143e39361b811713478be2acfa510832e63d47` | `17dc43d193a90de8dcaaaf9c3b29a5cf01a507d0` |
| 75 | `c0ba541fc113fad483cdf6cfb86732572b858b5f` | `e014e1ad4bcd7fa452d1dc2409613cf3f839ad90` |
| 76 | `0abd032e253556fe2995dd5e4ca288da82b47a6e` | `62f0dc0053e136b9e9e9c4ed76e5d88359bc8eaa` |
| 77 | `7e8b6a8d476742e24eed7489e8f77606c8ed2a21` | `9765811000f919e3637dddc0f3498d9160f56080` |
| 78 | `d2e9c1c2761cee47ecb8c186c883bc33696512d2` | `91f6e2d847ca00fc4321338abb89d3da86aa7bec` |

## Corrected replay evidence (ODD-DELIVERY-005; independent verification pending)

Backup `refs/heads/backup/prepare-public-portfolio-before-registration-fix` points to `cffccb0c0acb69d5934427d3d8322a4631eb35d2`; old ancestor `a3faf9324e1ca3184ebc2822f4024b187fdc83cd` maps to corrected base `0cb6eda932b7b59a1fff5360bfa48a88ef5a42b7`. New tip: `5dca299482d96f7eeaa40af1dbd952b09b6a7563`. All 76 old/new descendants pair ordinally with identical subjects; the original 75 descendants remain and descendant 76 is ODD evidence. SHA-256 of ordered UTF-8 subjects joined with newline (including trailing newline): `66ef688086afe4ee89979721c837a6cde511113cf4d507c9f7e7e2239e9a6bcf`; SHA-256 of ordered full `old new` pairs separated by newline (including trailing newline): `5566c947f074acc71a936380a363a6dabbb31f2c59db656405cbe9b2a2a55a94`. Final tracked tree equals the backup tree (`e0dc4e381eca17b22a16c7e017d13faef2215a36`). The provisioning checkpoint `f31d1c80ba7ca0d20beba0c267665574c48baa55` maps to `8c0299fc5bcc30644661df3fb1731cdb8536781e`, where Functions registration is first restored. Before this documentation edit, only `.pi/` was untracked. Earlier blocked-preflight evidence above describes the former state, not the current branch. The 76-pair ledger and 36 snapshot boundaries were independently verified; this document's future commit is a 77th descendant with no old counterpart and cannot contain its own full hash. Its final identity and measurement require post-commit verification.

| Ordinal | Old commit | Corrected commit |
| ---: | --- | --- |
| 01 | `8723f09f96bacda3440aac2cc659f6d13c32895e` | `473c8629d0edd29fbb81ecbb339098004e58c71b` |
| 02 | `8a5c7f60a718e97861c876b0bdfcdaf348b45bf2` | `ff245fab993e7995bf471e961a293becddd578c5` |
| 03 | `10c6a2c8ca57bdf87832572b28136185896cc0ea` | `fc5ef13430f9301e97ebbcb9346607f887da724b` |
| 04 | `2200c9e34ba54d36bc961afce42b147424feaf62` | `47e9d57dd2922b37e0972422de554ec7a9fc0250` |
| 05 | `15632a76124b382b143bad2d78d4b219506b1571` | `9d19c0e63a0be62ad58072c8e7fd578c91e2e049` |
| 06 | `fd3bca2a08aef25f21dc069f0b8af082660a1b32` | `63a989bc54dde748f471694490bc0ec7c508ad9d` |
| 07 | `7951ed7b772b5ba31d430979aaae6b116212dc61` | `d980718a63c5752d4a7c8390a5ec2a66e6668777` |
| 08 | `3954772ba99a6014b7ca7b6cb66fbdc150c4cdf9` | `518f774349787a8f97a899517690cb345be3e8c7` |
| 09 | `5c2a92ac074aa26be585d5121434511f7950b6a6` | `b66602c4395821d0ba69583ada1169bd8f06ab2b` |
| 10 | `55ad4c9db63c08f0006bbf1de962092afb794bce` | `d595a1a8b5367c3986b2ca7477a86b957daa246c` |
| 11 | `8e0831af48af216b867210166d78bdd903c1337d` | `01a74279f87c215e4303dad63fe50b1d900b35c6` |
| 12 | `d3dc4f51eccb28b8aa84dad103acf92c8621f658` | `d3fde58cfa176a07f9fd23743a3e3b4d14edf956` |
| 13 | `9f4178700da0e0e4e8543cffedc8ba598223c58d` | `3b19b7e5f9e9435aafd443a522abc13d0ff1e0c1` |
| 14 | `40afe83da941a88f69a2b858a26cb163610ab55d` | `6294290814e8aaaade9fa8a617c43c4c814386b3` |
| 15 | `8c707ec112c1d0f796f299e99b89878f9e6e16b5` | `55af1b26169ae21ec20cdf1f6d3c59ca6a50231a` |
| 16 | `5fbffb44f8d1eb142340e82fa804873169bc98a3` | `9442a7bfa0ca81fafd17a0ee487d8aa052e02cb9` |
| 17 | `d6336ec530611448fba0c91e8308a148a657b030` | `d245050d3eb6f43ebc32d9201cb77fe8f1886549` |
| 18 | `690c5277a961e9fdfb9365cf6563ce5eae4cb480` | `7712235384095fbfb3028a89d9615e8006bb78af` |
| 19 | `7fe44bc1a548a9dc11aeeb422091c68ec124a834` | `4533f6ec6d82931a92d0c50d619d353cafd7ceec` |
| 20 | `07ea16525b00ff86e1c214857b12161620973480` | `655876fa10c30c1c1f118abf614ce9256d116659` |
| 21 | `f5bec0b0dd5b02fd6364be3ab775a717d4e54c8d` | `092bd7bdd57106f8e1375d234dd19164a912ac28` |
| 22 | `f31d1c80ba7ca0d20beba0c267665574c48baa55` | `8c0299fc5bcc30644661df3fb1731cdb8536781e` |
| 23 | `13a90b7dfee2007b046f7e346cb0615b45791ddf` | `4376508c725167a0958397bb5073d26eb6d7fd10` |
| 24 | `bb5d4308b1a03096452e09cbc51ea6166ac60105` | `bf41f9d6b8d8e07f4e7d21c376b865b0344c5100` |
| 25 | `2acd50399a3521adbfde0ecb62d3b5bc7c85f8f5` | `ef4d287e1ec97abb2988735875e0eabd07ba7135` |
| 26 | `605d500ae204c693d311c604a8b2eadd2d3df296` | `04a0cb73abeba9b881e34957ac25c11ef5c8b494` |
| 27 | `494f86c0852c8a4c05808b2a75b627b5da4dda49` | `74fc43530c7ee1e278c7fc1811cf64b4ab1c3783` |
| 28 | `57e01e3575dfd6e65ad31c188cff6616a0adaa6a` | `60fa385c760ec787ab434d03a25e7bd3598765cc` |
| 29 | `4f7bc1cbe7a160bad4e9755e8d03c08569ebedc3` | `bfe58dd18acfdbccc4bb145dab99e8916d8f14a3` |
| 30 | `185fb89b513a1373dfc88a1be6e9336db006ac4c` | `d8775817ad51933603a2942c850454c8a4e90dff` |
| 31 | `3a38f35caca992430ad2e27c3cc8176881fb7db3` | `4d9949b24af0014b0913bd31c262fe5447a33c75` |
| 32 | `bbc26fc3c36754953d21430d9aa485b71f22ab4e` | `bbba513bdf16e2511f7ccc4ef2a17eb94dadf271` |
| 33 | `ea6c0a02010ec98b27864ed74dc4071d030513af` | `1bf54b072cc278b16e1ef2183312cb40a46bfffb` |
| 34 | `1a1c71ebe0f4b24828931e882960d4a5ca4cb7fd` | `6fcc448135417e0d557d52a79387bb69726c90fe` |
| 35 | `d1b6791dcc34b918d9395ffd3975dd1abc5aa9c5` | `921462fdbbce6fdc6a5f50a76d5c8a1b6e7f6002` |
| 36 | `e52c4b04af2ed4441bf83af1532133185d3a2f1c` | `9f2be2f90bc01fb532c80fb7278b13c31378441d` |
| 37 | `f8856a31e9b3bc35fb55f6dc6782d28b5ed907a5` | `4bf079cb0a4b634337a454a7c0da48be9fcd4e75` |
| 38 | `d43be5c27a85372c6ad5f86133da6c67fe0467ff` | `77d1f4a487eaa70c044d079b34fc9ff12128bce5` |
| 39 | `a55fba45f1e579a637c46e53f1f6e15242df82d4` | `b3e60ac31c39671c32da5169556f19872e3bc918` |
| 40 | `a450bd28bb08f58dad0ea02af529afefb628fe88` | `6b83667819f403fc7801f00b63e33178a0785651` |
| 41 | `1905d993f284f318d5f94e3dd177c60b89a95452` | `57252a50365f0f6cb6ce8b1ff7a0bcdaa530366e` |
| 42 | `2f94fe308d07c1a2a0fa1240a08b2cbf7076ff1c` | `d2aa8bae0c6f2c1188f2ca0586d28a78b8dce7ce` |
| 43 | `897eee689e77bdf7f77681ca6111c57231c152d2` | `8ba75c19049fa06b62163725c4fffde3a6fab7d3` |
| 44 | `e93afbba348742db4371bb2de5394a6b85a117bc` | `3ed55351d3cc4594cd56bad6e08c38886f6ed3e3` |
| 45 | `99c5be7fbd587a1c7f273b8cf1e01a81e53311ac` | `d560c985919b4a5f820d96caf9bbb39289f64f14` |
| 46 | `3699a21da9fd105aa42887399a3daa0c5fd1de16` | `4455dcfa5a9318ebb473996e9c7e1aca3c72a723` |
| 47 | `c2b9094b99f7aeb4abf00277b6118dbfa88230cd` | `c7a52d38b9c2748b8242ba2817ef5b6f72c23f47` |
| 48 | `4edb048152521f5d9508c72bc425c1933f5c3f9b` | `00db07e24be62161a7cce6c6bfa06b47efc6eccf` |
| 49 | `ac7bb3568b115d4e5b1ef8b3a034c2d9d8c6d949` | `d1fc6a17a3e9c60951692f23bdd4b6cc37f2896c` |
| 50 | `72455052c8b0fcb8c6ad7b44437ef573ffa7abb4` | `c326a390c0709b9be99b593f3465856a2ef76e80` |
| 51 | `2694f91aa62b266292359238d275bfaf92800ade` | `abb4692c408a9814af48f6a693c4a1624d6b5fc2` |
| 52 | `28db35fd65ccbe2a4df60025f2fe382ea96da5d8` | `b24ddd95d2b0d08a5f52d3b49eded5978f834fec` |
| 53 | `5645af09fc18de39173f2a0dd641ae99ce358f28` | `4315f896f56b76122c303b09935a69beda0e4758` |
| 54 | `d7e964ccb2aeeaf687eb8a696d95329ed5208173` | `74f280efcda4f43757f7dfc5473caf76e9b590a7` |
| 55 | `f62dea3ee284567965c396503508046c5320054c` | `dd72a0a49a8aa42c9fe0dfa66f8623398553f7cb` |
| 56 | `296f06a17a426e08e5b82a32d366e5a98271cbe8` | `4d15fdb5bf5a3c6013f2907472156acfcbc648f5` |
| 57 | `2797948c0dbb83b67d235646e08242e7e4d65a86` | `795e95645938de760129686172f664670a918c71` |
| 58 | `1981fd8adf50580843466361b7cdd0f40bc0ca2e` | `9afc45b6706fb053499cc953c238409ba4b7e6db` |
| 59 | `367400cc285d548bc038b4a5543ba48cc51fe1f7` | `464d102151359a754307c7106ff77522c0bc2a2f` |
| 60 | `d80f84b9da1efd6c51feb6fc2b4978a4e6908bce` | `c9dbc35123b1d76dde5a0f328014463f2e823f8e` |
| 61 | `634763e0275e3493e9623b972faa2db4452c4168` | `2f5457eb9ed58512c08060b757ed2bdcfeee797a` |
| 62 | `605c18622377b9472872ced200212da27f5e3e03` | `3100fc331ab4910dc0feea4894499237428e4d58` |
| 63 | `e272a3518fab9260c005e29360dbcd2f0f674d16` | `b52a3dda3cfecf41f45edb55107c3634432e31f2` |
| 64 | `041e490e33f7fc0e8af78ab3d3890ce3be92b7b1` | `58ee4b2121b3cf9d172782ba8dd5b7814444587d` |
| 65 | `9daca252d92554eadccca2f2ebb9bfdf032776ea` | `f8f9b8716fe58ab62216d4491f23a8ae0e54d768` |
| 66 | `b3f3dc604ca458dc23624b5a930ab8fa5a961a78` | `c93dbe5a6615e6c06fdc891dd8c20de5745fe685` |
| 67 | `17dc43d193a90de8dcaaaf9c3b29a5cf01a507d0` | `de65c88589eaeb5127d91f809a818c159dd4a465` |
| 68 | `e014e1ad4bcd7fa452d1dc2409613cf3f839ad90` | `b9322bafbea3889e38724b3df88d3b1933c7f2ab` |
| 69 | `62f0dc0053e136b9e9e9c4ed76e5d88359bc8eaa` | `f46f0fd96f41f3cb46a469158d7a1308db81b9f8` |
| 70 | `9765811000f919e3637dddc0f3498d9160f56080` | `aafba2049baf408adce6d667b4903d75a552fdd7` |
| 71 | `91f6e2d847ca00fc4321338abb89d3da86aa7bec` | `9c3834be97c59d45baeeb266247cca62512e3a42` |
| 72 | `5b0ea53b7d8d54d50e03813fb4d098220cdc3e16` | `64bba6aa5db4d959ab6a794db2e63ae9f76fb642` |
| 73 | `6fc919f8c44e3f47b6a171342a2788e707995e61` | `7a663ef2ff98700d32574e125463652d470b767f` |
| 74 | `30f37d182478d4bb7e13d79c0a6b511c178dcbb1` | `786b1dd95ac34030b58abe77b83cf5e03613a905` |
| 75 | `6b95978162a9c0debce04e98c96d1d4a91fb1675` | `876f355c97aca16a173194a450cd719bc743a2e6` |
| 76 | `cffccb0c0acb69d5934427d3d8322a4631eb35d2` | `5dca299482d96f7eeaa40af1dbd952b09b6a7563` |

### Corrected 36-boundary measurements

Historical topology and exception decisions above remain intact. Rows 1–5 are unchanged; row 6 includes both the original scaffold `a3faf9324e1ca3184ebc2822f4024b187fdc83cd` and its correction, ending at the corrected base; rows 7–35 map endpoints ordinally; row 36 extends through the final ODD evidence commit. Every slice uses `git diff --numstat` from the preceding corrected endpoint (row 1 from `origin/master`) to its endpoint. Binary files contribute no numeric lines. These slice sums are **not** the net base-to-tip diff. The old exception approvals do not automatically apply to changed totals.

| Position | Branch | Inclusive corrected range | Additions | Deletions | Total | Historical exception |
| ---: | --- | --- | ---: | ---: | ---: | --- |
| 01 | `feat/chain-bootstrap-format` | `c6f96c00c3b8446529fe6968ad15b80839052e28..74da2905faa37b11bfd8db96dee1041dbcbdbf6d` | 732 | 122 | 854 | `size:exception` |
| 02 | `feat/remove-status-artifact` | `c519885bc4991183cd26965e415290770efc85bc..c519885bc4991183cd26965e415290770efc85bc` | 0 | 114 | 114 | — |
| 03 | `feat/migrate-portfolio-openspec` | `4aab9ac66e9e303c9dd2c9b60d7ad7f7e77e5bb9..4aab9ac66e9e303c9dd2c9b60d7ad7f7e77e5bb9` | 733 | 0 | 733 | `size:exception` |
| 04 | `feat/remove-demo-credentials` | `88c6ee50a0199426ec3f512ebc99792c6e134ae4..88c6ee50a0199426ec3f512ebc99792c6e134ae4` | 273 | 217 | 490 | `size:exception` |
| 05 | `feat/clarify-deployment-status` | `9542895a2451e47ccb3794d513f8563cf9f36e4a..9542895a2451e47ccb3794d513f8563cf9f36e4a` | 112 | 3 | 115 | — |
| 06 | `feat/functions-dependency-scaffold` | `a3faf9324e1ca3184ebc2822f4024b187fdc83cd..0cb6eda932b7b59a1fff5360bfa48a88ef5a42b7` | 3094 | 1 | 3095 | `size:exception` |
| 07 | `feat/provisioning-contract-model` | `473c8629d0edd29fbb81ecbb339098004e58c71b..9d19c0e63a0be62ad58072c8e7fd578c91e2e049` | 3583 | 104 | 3687 | `size:exception` |
| 08 | `feat/validated-provisioning-constructors` | `63a989bc54dde748f471694490bc0ec7c508ad9d..d595a1a8b5367c3986b2ca7477a86b957daa246c` | 2071 | 109 | 2180 | `size:exception` |
| 09 | `feat/cas-reducer-lease-contract` | `01a74279f87c215e4303dad63fe50b1d900b35c6..3b19b7e5f9e9435aafd443a522abc13d0ff1e0c1` | 494 | 118 | 612 | `size:exception` |
| 10 | `feat/portfolio-baseline-reconciliation` | `6294290814e8aaaade9fa8a617c43c4c814386b3..d245050d3eb6f43ebc32d9201cb77fe8f1886549` | 114 | 0 | 114 | — |
| 11 | `feat/outbox-race-coverage` | `7712235384095fbfb3028a89d9615e8006bb78af..4533f6ec6d82931a92d0c50d619d353cafd7ceec` | 191 | 3 | 194 | — |
| 12 | `feat/retry-conformance-coverage` | `655876fa10c30c1c1f118abf614ce9256d116659..092bd7bdd57106f8e1375d234dd19164a912ac28` | 141 | 2 | 143 | — |
| 13 | `feat/accepted-provisioning-checkpoint` | `8c0299fc5bcc30644661df3fb1731cdb8536781e..4376508c725167a0958397bb5073d26eb6d7fd10` | 13603 | 436 | 14039 | `size:exception` |
| 14 | `feat/crash-reconstruction-coverage` | `bf41f9d6b8d8e07f4e7d21c376b865b0344c5100..ef4d287e1ec97abb2988735875e0eabd07ba7135` | 243 | 2 | 245 | — |
| 15 | `feat/terminal-concurrency` | `04a0cb73abeba9b881e34957ac25c11ef5c8b494..74fc43530c7ee1e278c7fc1811cf64b4ab1c3783` | 342 | 119 | 461 | `size:exception` |
| 16 | `feat/freeze-p3-backend` | `60fa385c760ec787ab434d03a25e7bd3598765cc..bfe58dd18acfdbccc4bb145dab99e8916d8f14a3` | 281 | 60 | 341 | — |
| 17 | `feat/trusted-callable-transport` | `d8775817ad51933603a2942c850454c8a4e90dff..d8775817ad51933603a2942c850454c8a4e90dff` | 231 | 36 | 267 | — |
| 18 | `feat/p4-flutter-compatibility` | `4d9949b24af0014b0913bd31c262fe5447a33c75..bbba513bdf16e2511f7ccc4ef2a17eb94dadf271` | 90 | 18 | 108 | — |
| 19 | `feat/reconciled-chain-preparation` | `1bf54b072cc278b16e1ef2183312cb40a46bfffb..6fcc448135417e0d557d52a79387bb69726c90fe` | 79 | 71 | 150 | — |
| 20 | `feat/early-gate-stabilization` | `921462fdbbce6fdc6a5f50a76d5c8a1b6e7f6002..9f2be2f90bc01fb532c80fb7278b13c31378441d` | 110 | 57 | 167 | — |
| 21 | `feat/portable-staged-formatter` | `4bf079cb0a4b634337a454a7c0da48be9fcd4e75..4bf079cb0a4b634337a454a7c0da48be9fcd4e75` | 273 | 250 | 523 | `size:exception` |
| 22 | `feat/callable-contract-mapping` | `77d1f4a487eaa70c044d079b34fc9ff12128bce5..b3e60ac31c39671c32da5169556f19872e3bc918` | 635 | 4 | 639 | `size:exception` |
| 23 | `feat/resilient-status-polling` | `6b83667819f403fc7801f00b63e33178a0785651..6b83667819f403fc7801f00b63e33178a0785651` | 545 | 0 | 545 | `size:exception` |
| 24 | `feat/employee-creation-ux` | `57252a50365f0f6cb6ce8b1ff7a0bcdaa530366e..57252a50365f0f6cb6ce8b1ff7a0bcdaa530366e` | 765 | 1018 | 1783 | `size:exception` |
| 25 | `feat/retire-direct-client-creation` | `d2aa8bae0c6f2c1188f2ca0586d28a78b8dce7ce..d2aa8bae0c6f2c1188f2ca0586d28a78b8dce7ce` | 55 | 538 | 593 | `size:exception` |
| 26 | `feat/firestore-user-write-hardening` | `8ba75c19049fa06b62163725c4fffde3a6fab7d3..8ba75c19049fa06b62163725c4fffde3a6fab7d3` | 1936 | 129 | 2065 | `size:exception` |
| 27 | `feat/p4-final-gate-checkpoint` | `3ed55351d3cc4594cd56bad6e08c38886f6ed3e3..c7a52d38b9c2748b8242ba2817ef5b6f72c23f47` | 112 | 67 | 179 | — |
| 28 | `feat/wu5-toolchain-transition` | `00db07e24be62161a7cce6c6bfa06b47efc6eccf..b24ddd95d2b0d08a5f52d3b49eded5978f834fec` | 345 | 40 | 385 | — |
| 29 | `feat/visible-app-branding` | `4315f896f56b76122c303b09935a69beda0e4758..dd72a0a49a8aa42c9fe0dfa66f8623398553f7cb` | 129 | 25 | 154 | — |
| 30 | `feat/repository-sanitizer` | `4d15fdb5bf5a3c6013f2907472156acfcbc648f5..4d15fdb5bf5a3c6013f2907472156acfcbc648f5` | 245 | 0 | 245 | — |
| 31 | `feat/sanitize-portfolio-configuration` | `795e95645938de760129686172f664670a918c71..9afc45b6706fb053499cc953c238409ba4b7e6db` | 84 | 108 | 192 | — |
| 32 | `feat/portfolio-quickstart` | `464d102151359a754307c7106ff77522c0bc2a2f..464d102151359a754307c7106ff77522c0bc2a2f` | 77 | 208 | 285 | — |
| 33 | `feat/retire-deployment-claims` | `c9dbc35123b1d76dde5a0f328014463f2e823f8e..2f5457eb9ed58512c08060b757ed2bdcfeee797a` | 11 | 387 | 398 | — |
| 34 | `feat/portfolio-readme` | `3100fc331ab4910dc0feea4894499237428e4d58..b52a3dda3cfecf41f45edb55107c3634432e31f2` | 25 | 326 | 351 | — |
| 35 | `feat/remove-archived-history` | `58ee4b2121b3cf9d172782ba8dd5b7814444587d..f8f9b8716fe58ab62216d4491f23a8ae0e54d768` | 2 | 7633 | 7635 | `size:exception` |
| 36 | `feat/final-portfolio-ci-and-closure` | `c93dbe5a6615e6c06fdc891dd8c20de5745fe685..5dca299482d96f7eeaa40af1dbd952b09b6a7563` | 275 | 26 | 301 | — |

Snapshot through `5dca299482d96f7eeaa40af1dbd952b09b6a7563`: 32,031 additions / 12,351 deletions / 44,382 total across slices, not the net aggregate diff. The maintainer accepted fresh local exception totals 3095 (row 06), 14039 (row 13), and 429 (row 36 including this document-only commit); all other historical exception totals remain unchanged. Row 36 above measures 301 at the snapshot tip; its 429-line final boundary is contingent on the exact post-commit measurement. This approval does not authorize publication.
