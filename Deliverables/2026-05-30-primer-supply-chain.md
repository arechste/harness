---
form: explanation
last-verified: 2026-05-30
owner: RECON (research); TOWER (synthesis)
status: draft
audience: principal
---

# Supply-Chain Security — Plain-Language Primer

**Purpose:** Build shared vocabulary before picking a posture for harness. Nothing is decided here; decisions come after reading this together.

**Companion documents:**
- `Deliverables/2026-05-30-signing-and-security-standards.md` — the roadmap this feeds into
- `Team Knowledge/Guidelines/GL-005-code-of-conduct.md` — current supply-chain floor (Tier 0)

---

## 1. The Threat Model — What Is a "Supply-Chain Attack"?

Your code is not just the files you write. It is also every library you import, every build tool that processes it, and every artifact (binary, container image, release zip) that lands in a consumer's hands. A supply-chain attack targets any of those links instead of your own code.

The four main vectors:

| Attack type | Plain description | Famous example |
|---|---|---|
| **Typosquatting** | Attacker publishes `reqeusts` to PyPI hoping developers mistype `requests`. Package executes malicious install scripts. | Throughout 2024, PyPI removed hundreds of malicious typosquats per month — `requets`, `colorama-py`, `selemium`. |
| **Dependency confusion** | Attacker publishes a public package with the same name as your internal private package. Package managers can be tricked into pulling the public one. | 2021: security researcher Alex Birsan demonstrated this against Apple, Microsoft, PayPal. |
| **Compromised build** | Attacker gains access to the build system and inserts malicious code into an artifact before it ships. | SolarWinds (2020): backdoor injected into the Orion build pipeline, reaching 18,000 organizations including U.S. government agencies. |
| **Tampered release artifact** | A legitimate release is replaced or modified after the build, between the build server and the consumer's download. | XZ Utils (2024): a patient, multi-year maintainer takeover attempt inserted a backdoor into a core Linux compression library. Caught by one engineer noticing SSH was inexplicably slow. |

The common thread: **you trust something you did not personally build from audited source.** Supply-chain security is the practice of verifying that trust rather than assuming it.

---

## 2. SLSA — Build Provenance (what it is and what each level proves)

**SLSA** (pronounced "salsa") stands for **Supply-chain Levels for Software Artifacts**. It is a framework from Google/OpenSSF that answers one question: "How confident are we that this artifact actually came from the source code and build process we think it did?"

It does this by defining **provenance** — a cryptographically signed document that says "artifact X was built from commit Y by workflow Z on platform P at time T." Think of it as a birth certificate for a binary.

SLSA v1.0 defines four build levels:

| Level | Plain name | What it proves | What it requires | Effort |
|---|---|---|---|---|
| **L0** | No claim | Nothing. No provenance at all. | — | Zero |
| **L1** | Provenance exists | Someone wrote down how this was built. Easy to forge, but rules out simple mistakes and deters casual attackers. | Generate and attach a provenance file to releases. | Low |
| **L2** | Hosted build + signed provenance | The build ran on a hosted platform (not someone's laptop), and the provenance is cryptographically signed by that platform. Forging it requires exploiting a real vulnerability. | CI platform that can issue signed provenance (GitHub Actions qualifies). | Low-Med |
| **L3** | Isolated build + hardened platform | The build ran in an isolated environment where even the workflow itself cannot tamper with the provenance generator. Strong protection against insider threats and compromised credentials. | Use `slsa-github-generator` reusable workflows (isolates the signing job from your build job). | Med |

Note: SLSA v0.1 had a level 4, but v1.0 stops at L3. The old "L4" concepts were rolled into L3's requirements.

**What GitHub gives you for free (on public repos):**

GitHub's built-in `actions/attest-build-provenance` action gets you to **SLSA v1.0 Build Level 2** with roughly five lines of YAML added to any release workflow. The action generates a signed provenance statement, stores it in GitHub's Sigstore-backed transparency log, and lets any consumer verify it with `gh attestation verify`. No external keys to manage.

For **L3**, you swap to the open-source `slsa-framework/slsa-github-generator` reusable workflow. This runs the signing in a completely separate job from your build, so a compromised build step cannot forge the provenance.

**Important caveat for private repos:** GitHub's artifact attestations are free for public repos on all plans. For private repos you need GitHub Enterprise Cloud, or you run `slsa-github-generator` yourself (which calls Sigstore's public Fulcio/Rekor services — workable, but the provenance is then stored in a public transparency log even for a private artifact). For a private fleet, L1 (generating a provenance file manually) and strong CI hygiene are the pragmatic substitute until you go public.

---

## 3. SBOM — Software Bill of Materials

An **SBOM** (Software Bill of Materials) is an exact inventory of every software component in your project — your direct dependencies, their dependencies, all the way down, with version numbers and license identifiers. Think of it as the ingredient list on a food package, but for code.

**Why it matters:**

Without an SBOM, when a new critical vulnerability (CVE) is announced, you must manually grep through lockfiles hoping you have not missed an indirect dependency. With an SBOM, you feed it to a scanner and get a yes/no answer in seconds.

**The two dominant formats:**

| Format | Who owns it | Best fit |
|---|---|---|
| **SPDX** (Software Package Data Exchange) | Linux Foundation | License compliance, legal teams, US government requirements |
| **CycloneDX** | OWASP | Security-first; richer vulnerability metadata |

Both are machine-readable JSON or XML. Both are well-supported. CycloneDX is the more security-native choice; SPDX is required if you ever sell to U.S. federal agencies (per Biden/Biden-successor executive orders). Using either is better than neither; most tools generate both.

**The primary toolchain:**

- **syft** (by Anchore): scans a repo, container image, or directory and generates an SBOM in your chosen format. One command, works on any language. Active as of 2025 (v1.20.0 in Feb 2025).
- **grype** (by Anchore): takes an SBOM (or scans directly) and matches components against vulnerability databases (NVD, GitHub Advisory). Produces a prioritized list of findings.
- **trivy** (by Aqua Security): does both SBOM generation and vulnerability scanning in one tool; good alternative if you want fewer moving parts.

**What it costs:** adding `syft` and `grype` to a CI job takes about 30 minutes and adds a couple of minutes to build time. The output SBOM is an artifact you attach to the release.

**What it buys:** fast CVE response, license inventory, and a credible answer when any future enterprise customer asks "do you have an SBOM?" (They will ask.)

---

## 4. Artifact and Tag Signing — What "Signing a Release" Means

**The problem without signing:** You download a release binary. How do you know it is the same bytes the build server produced, and not something swapped in transit or after the fact?

**Signing** attaches a cryptographic proof to an artifact or git tag. Anyone who has the public key (or access to a transparency log) can verify: "this exact file was signed by identity X." If even one byte changes after signing, verification fails.

**Two tools in this space:**

**cosign** (from the Sigstore project): signs container images, release binaries, SBOM files — anything with a hash. It supports both traditional key-based signing and "keyless" signing.

**Keyless signing (Sigstore model):** Instead of "signed by private key K" (who holds key K? what if it leaks?), keyless uses your CI platform's identity. In a GitHub Actions workflow, cosign asks GitHub for a short-lived OIDC token ("I am the workflow at github.com/org/repo, commit abc, triggered by push"), exchanges it for a 10-minute certificate from Sigstore's **Fulcio** CA, signs the artifact, records the event in **Rekor** (a public, append-only transparency log), then discards the key. Nothing to rotate, nothing to leak.

What a consumer verifying your release gets: "this artifact was signed by GitHub Actions running in org/repo at commit abc." Not just "signed by some key."

**Signed git tags:** A standard `git tag -s v1.0.0` uses your GPG key to sign the tag object. GitHub shows a "Verified" badge. This proves the tag was created by whoever holds the key, not that the release artifact itself is unmodified.

**Comparison table:**

| Method | What it signs | Key management | Verification UX |
|---|---|---|---|
| `git tag -s` (GPG) | The git tag commit pointer | You manage GPG key | `git tag -v` or GitHub badge |
| `cosign` key-based | Any artifact (image, binary, SBOM) | You manage cosign keypair | `cosign verify` with public key |
| `cosign` keyless (Sigstore) | Any artifact | None — CI identity is the key | `cosign verify --certificate-identity` against transparency log |
| GitHub `actions/attest` | Artifacts produced in GHA workflows | None — GitHub manages it | `gh attestation verify` |

For harness's use case (small team, private-to-OSS journey), keyless via GitHub's built-in attestation is the pragmatic path: zero key management, strong verification story for future consumers.

---

## 5. OpenSSF Scorecard — The Automated Health Check

**OpenSSF** is the **Open Source Security Foundation**, a Linux Foundation project. It produces tools and standards for improving open-source software security.

**Scorecard** is one of its tools: an automated scanner that runs against a GitHub repository and produces a score from 0 to 10 based on 18+ security practices. Think of it as a report card for your repo's security hygiene.

**What it checks (selected):**

| Check | What it looks at |
|---|---|
| Branch Protection | Are merges to main gated by review or CI? |
| Dependency Update Tool | Is Dependabot or Renovate enabled? |
| Pinned Dependencies | Are actions and dependencies pinned to digests/hashes, not just tags? |
| SAST | Is any static analysis scanner running in CI? |
| Signed Releases | Are release artifacts signed? |
| Token Permissions | Do CI workflows request minimal permissions? |
| Code Review | Does every change get reviewed before merge? |
| Maintained | Has the project had recent activity? |

**What a score means in practice:** A score of 7+ is generally considered healthy for an open-source library. Below 5 is a red flag for a dependency you are about to take on. For your own repo, you want to understand and consciously accept any low-scoring check, not just maximize the number.

**Running it:** There is an official `ossf/scorecard-action` GitHub Action. Add it to `.github/workflows/scorecard.yml` and it posts results to GitHub's security dashboard (Code Scanning tab). About 15 minutes to configure.

**What it buys for harness:** When you go public, any serious downstream user may run Scorecard on your repo before adopting it. Having a published score above 7 is a trust signal. Running it yourself in CI means you catch regressions before consumers do.

---

## 6. NIST SSDF — The Umbrella Framework (one paragraph)

**NIST** is the U.S. National Institute of Standards and Technology. **SSDF** stands for **Secure Software Development Framework**, published as Special Publication 800-218 (v1.1 current; v1.2 draft as of late 2025). It is the U.S. government's recommended checklist for secure software development practices, organized into four groups: Prepare the Organization (governance, tooling, roles), Protect the Software (source integrity, access control), Produce Well-Secured Software (design, testing, vulnerability management), and Respond to Vulnerabilities (disclosure, patching, post-mortems). SLSA, SBOM, and Scorecard are all concrete implementations of specific SSDF practices — SSDF is the umbrella framework that names the outcomes, while those other tools are how you prove you met them. U.S. federal contractors are expected to self-attest SSDF compliance per OMB M-23-16. For a private project heading toward OSS, knowing the framework by name means you can credibly map your practices to it when enterprise or government consumers ask.

---

## 7. The Staged Ladder — Where Harness Is and Where to Go

This is the practical section. Each tier is an honest answer to "what do you get, what does it cost, and when does it pay off?"

### Current State — Tier 0 (GL-005 floor)

Already in place per GL-005:
- Dependency pinning + lockfiles reviewed on PRs
- `npm audit` / `cargo audit` / `pip-audit` in CI
- No `curl | sh` installs; checksums verified where available
- Registry preference (canonical registries, no vanity URLs)
- New deps reviewed for maintainer reputation before adding

**Verdict:** Solid hygiene baseline. Does not prove anything to an external consumer; does not produce any artifacts a downstream can verify. Sufficient for a private fleet with no external consumers.

---

### Tier 1 — Provenance + SBOM (low effort, high signal)

**What you add:**

| Action | Tool | Effort |
|---|---|---|
| Generate SBOM on every release | `syft` in CI | ~30 min setup |
| Scan SBOM for CVEs on every CI run | `grype` in CI | ~15 min setup |
| Attach SBOM as release artifact | CI release step | ~15 min setup |
| Generate SLSA L1 provenance (a signed document describing the build) | `actions/attest` or manual provenance JSON | ~30 min setup |
| Pin all GitHub Actions to SHA digests | `pin-github-action` or manual | ~1 hr one-time |

**Total effort:** Half a day.

**What it buys:**
- You can answer "what's in this release?" instantly.
- CVE response time drops from "grep lockfiles and hope" to "run grype, get a list."
- SLSA L1 provenance on releases deters casual tampering and makes the build process auditable.
- Action pinning closes a real attack vector (a compromised action tag could inject malicious code into your build).

**When does it earn its cost?** Immediately. The CVE scanning alone pays for itself the first time a major vulnerability hits a transitive dependency. Action pinning is pure hygiene with zero ongoing cost.

**Hassle-theater assessment:** Not theater. All four items have direct defensive value even for a fully private fleet.

---

### Tier 2 — SLSA L2 + Signed Releases + Scorecard (medium effort, public-readiness signal)

**What you add:**

| Action | Tool | Effort |
|---|---|---|
| SLSA L2 provenance on releases (hosted, signed build) | `actions/attest-build-provenance` | ~1 hr (5 YAML lines per release workflow) |
| Sign release artifacts (binaries, images) | `cosign` keyless in CI | ~2 hrs |
| Run OpenSSF Scorecard in CI | `ossf/scorecard-action` | ~1 hr |
| Address Scorecard findings above score 5 | Policy + CI config changes | ~4-8 hrs |

**Total effort:** One focused day.

**What it buys:**
- Any consumer can run `gh attestation verify` on your release and confirm it came from your repo's CI, not a compromised download mirror.
- Signed artifacts mean tampered releases fail verification visibly.
- Scorecard score is a public trust signal; fixing low-hanging Scorecard findings (token permissions, branch protection) also closes real attack surface.
- Going from private to public becomes nearly a non-event: you already have the provenance story and the score.

**When does it earn its cost?** When you have even one external consumer, or when you open-source the repo. If you open-source tomorrow, you want this already in place, not scrambling to add it.

**Hassle-theater assessment:** Mostly not theater, with one caveat. For a fully private fleet with no external consumers, signed release artifacts are modest theater — the verification story only matters if someone outside your own CI is downloading the artifact. The Scorecard work and SLSA L2 provenance have genuine internal value regardless.

---

### Tier 3 — SLSA L3 + Full SSDF Traceability (higher effort, enterprise/OSS-serious signal)

**What you add:**

| Action | Tool | Effort |
|---|---|---|
| SLSA L3 provenance (isolated signing job) | `slsa-framework/slsa-github-generator` reusable workflows | ~4 hrs + testing |
| SBOM published to a dependency-track or VEX-annotated endpoint | CycloneDX Dependency-Track or similar | Med-High |
| SSDF self-attestation document | Manual doc mapped to practices | ~1 day |
| SPDX SBOM alongside CycloneDX (for government-adjacent consumers) | `syft` supports both | ~1 hr |

**Total effort:** 2-4 days.

**What it buys:**
- SLSA L3 proves the provenance itself cannot be tampered with by the build, closing the insider/compromised-credential scenario.
- Dependency-Track gives you a continuous vulnerability dashboard across all repos, not just point-in-time scans.
- SSDF attestation is a precondition for U.S. federal procurement (OMB M-23-16).
- SPDX is the format required by U.S. government procurement and the EU Cyber Resilience Act.

**When does it earn its cost?** When you have enterprise customers who run security audits, or government/regulated-industry customers, or when the repos are widely-used OSS that attracts attacker attention. For an early-stage OSS project with no such customers yet, Tier 2 is the right stopping point and Tier 3 is genuinely forward-looking.

**Hassle-theater assessment:** Tier 3 items are not theater in the right context. In the wrong context (small OSS project, no enterprise buyers), they are significant overhead for marginal daily benefit. The sequencing matters: do Tier 1, then Tier 2, then assess whether Tier 3 is merited by the consumer base.

---

### Ladder summary table

| Tier | Key additions | Effort | Earn-it-when |
|---|---|---|---|
| **0** (have today) | Dep pinning, `npm/pip/cargo audit`, registry hygiene | Done | Always |
| **1** (recommended next) | SBOM (syft/grype), SLSA L1 provenance, action SHA pinning | ~4 hrs | Immediately — CVE response + hygiene |
| **2** (before going public) | SLSA L2 via `actions/attest`, cosign keyless signing, Scorecard | ~1 day | First external consumer / OSS day |
| **3** (OSS-serious / enterprise) | SLSA L3 via slsa-github-generator, Dependency-Track, SSDF attestation, SPDX | 2-4 days | Enterprise buyers / government-adjacent |

---

## Recommended Starting Point and Climb Schedule for Harness

**Start at Tier 1. Target Tier 2 before any repo goes public.**

Concrete recommendation:

1. **Now (this sprint):** Implement Tier 1 across all harness repos — syft + grype in CI, SBOM attached to releases, action SHA pinning. Half a day of work. This is pure hygiene with immediate defensive value and zero hassle-theater.

2. **Before first external consumer or any repo going public:** Implement Tier 2 — add `actions/attest-build-provenance` to release workflows, add `cosign` keyless signing, run Scorecard and address findings that score below 5. This makes the "go public" moment a non-event.

3. **Revisit Tier 3 when:** you have an enterprise or government-adjacent buyer asking for SSDF attestation, or a widely-adopted OSS library where supply-chain attacks become a realistic threat model.

**What this posture is not:** It is not the most paranoid possible posture. It is a genuine, credible, enterprise-grade posture that covers the realistic threat model for a private-to-OSS project without drowning in overhead.

---

## Decisions You Must Make

These cannot be made by the team alone — they require principal direction:

1. **Private-repo SLSA strategy:** GitHub's built-in attestations are free only on public repos. For private repos, do you accept L1 (manual provenance file) until go-public, or is GitHub Enterprise Cloud on the roadmap? This affects how much of Tier 2 you can implement today.

2. **SBOM audience:** CycloneDX is the security-native choice; SPDX is the government-procurement choice; syft generates both at marginal cost. Do you want one or both? The answer shapes the release artifact structure.

3. **Scorecard public visibility:** The `ossf/scorecard-action` posts results to GitHub's public security dashboard when run on public repos. For private repos it just surfaces findings internally. Do you want to display a public Scorecard badge on future repos as a trust signal to consumers?

4. **When do you expect to open-source, and which repos first?** The answer determines urgency of Tier 2. If it's 6+ months out, there's no rush. If it's 3 months out, start Tier 2 now so it's settled before the flag flips.

5. **Dependency-Track (Tier 3 prerequisite):** Running a continuous vulnerability dashboard requires a service (self-hosted or cloud). Is that infrastructure investment on the roadmap, or is CI-time-only scanning (grype) sufficient for the foreseeable future?

---

## Source References

- SLSA framework and levels: [slsa.dev/spec/v1.0/levels](https://slsa.dev/spec/v1.0/levels)
- GitHub SLSA L3 blog post: [github.blog — Enhance build security and reach SLSA Level 3](https://github.blog/enterprise-software/devsecops/enhance-build-security-and-reach-slsa-level-3-with-github-artifact-attestations/)
- GitHub artifact attestations docs: [docs.github.com — Using artifact attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
- `slsa-framework/slsa-github-generator`: [github.com/slsa-framework/slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator)
- `actions/attest-build-provenance`: [github.com/actions/attest-build-provenance](https://github.com/actions/attest-build-provenance)
- `anchore/syft`: [github.com/anchore/syft](https://github.com/anchore/syft)
- Sigstore/cosign: [docs.sigstore.dev/cosign](https://docs.sigstore.dev/cosign/signing/overview/)
- OpenSSF Scorecard: [scorecard.dev](https://scorecard.dev/)
- Scorecard checks reference: [github.com/ossf/scorecard — checks.md](https://github.com/ossf/scorecard/blob/main/docs/checks.md)
- NIST SSDF SP 800-218: [csrc.nist.gov/pubs/sp/800/218/final](https://csrc.nist.gov/pubs/sp/800/218/final)
- NIST SSDF v1.2 draft (Dec 2025): [nist.gov — SSDF v1.2 public comment](https://www.nist.gov/news-events/news/2025/12/secure-software-development-framework-ssdf-version-12-available-public)
- XZ Utils attack: [thebrightbyte.com — Supply Chain Attacks 2024-2026](https://thebrightbyte.com/playbook/insights/supply-chain-attacks-xz-npm-pypi)
- SolarWinds and supply-chain attack examples: [panorays.com — Real-World Supply Chain Attack Examples](https://panorays.com/blog/supply-chain-attack-examples/)
- CycloneDX standard: [cyclonedx.org](https://cyclonedx.org/)
- OpenSSF Scorecard scorecard.dev overview: [wiz.io — OpenSSF Scorecard Tutorial](https://www.wiz.io/academy/openssf-scorecard-overview)

---

*Source tiers: slsa.dev, docs.github.com, csrc.nist.gov, scorecard.dev, docs.sigstore.dev = Tier 1 (official vendor/standards docs). github.blog, anchore.com = Tier 2 (vendor blog/maintainer). panorays.com, thebrightbyte.com = Tier 3 (secondary reporting, used only for illustrative examples).*
