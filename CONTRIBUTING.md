# Contributing to Amnesic Ghost Framework

First off, thank you for considering contributing to the Amnesic Ghost Framework! It's people like you that make the open-source privacy community so powerful.

## How to Contribute
1. Fork the repository.
2. Create a new branch for your feature (`git checkout -b feature/SecurityEnhancement`).
3. Commit your changes (`git commit -m 'feat: add enhanced MAC spoofing'`).
4. Push to the branch (`git push origin feature/SecurityEnhancement`).
5. Open a Pull Request.

## Security & Coding Guidelines
- **No Hardcoded Paths:** Always use variables for paths so users can easily customize their setups.
- **Air-Gapped Mindset:** Ensure that core offline scripts (`ghost.sh`, `setup.sh`) **never** silently connect to the internet without explicit user permission.
- **ShellCheck CI:** All bash scripts must pass ShellCheck without warnings. Our GitHub Actions pipeline will automatically test your PR.
- **Minimum Privilege:** Avoid `sudo` unless absolutely necessary, and drop privileges when launching GUI applications (e.g., Mullvad Browser).

## Reporting Vulnerabilities
If you discover a security vulnerability within this framework (e.g., an IP leak vector), please **do not** open a public issue. Instead, reach out privately so we can patch it before it is exploited by adversaries.
