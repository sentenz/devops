# `/app`

Code analysis for DevOps or DevSecOps environment in `shift left` paradigm.

- `sast.sh`
  > Static Application Security Testing (SAST) is a `white box testing` process for analyzing application source code to identify sources of vulnerabilities.

  Options:

  - `-l` diff
    > Lint changes between the working tree and the git index.

  - `-l` staged
    > Lint changes staged for the next commit.

  - `-l` ci
    > Lint changes between the support branch and the base branch.

- `dast.sh`
  > Dynamic Application Security Testing (DAST) is a `black box testing` process for identifying vulnerabilities of the applications through penetration tests, memory leak idendification and with no access to its source code.

  Options:

  - `-b` <binary>
    > Sanitize compilation-based binary for memory misuse bugs of C/C++ programs.

- `sca.sh`
  > Software Composition Analysis (SCA) is an automated process that identifies the open source software in a codebase. This analysis is performed to evaluate security, license compliance, Software Bill of Materials (SBOM), and code quality. SCA isA software-only subset of Component Analysis.

  Options:

  - `-p` <path>
    > Scanner for vulnerabilities in container images, file systems, and Git repositories, and configuration issues and hard-coded secrets.
