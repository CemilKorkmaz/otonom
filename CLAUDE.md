# Otonom — ECC Agent & Engineering Rules

This project integrates specialist agents and skills from [`affaan-m/ECC`](https://github.com/affaan-m/ECC) under `.claude/agents/` and `.claude/skills/`:

## Active ECC Agents & Skills
- **`.claude/agents/flutter-reviewer.md`** & **`.claude/skills/flutter-dart-code-review/SKILL.md`**: Enforce Flutter/Dart clean architecture, `const` constructors, `RepaintBoundary` isolation, stream/timer disposal, `context.mounted` safety after `await`, and Dart 3.3+ compatibility (`(_, __)` instead of duplicate `_`).
- **`.claude/skills/liquid-glass-design/SKILL.md`**: iPhone / iOS Liquid-Glass UI design language (`BackdropFilter` frosted translucency, specular `0.6px` hairline borders, squircle radii, `CupertinoIcons`, `CupertinoSlidingSegmentedControl`, `BouncingScrollPhysics`, tactile `HapticFeedback`).
- **`.claude/agents/silent-failure-hunter.md`**: Zero tolerance for empty swallowed `catch (_) {}` blocks without status/error telemetry; reusable `http.Client` with explicit timeouts and structured error reporting.
- **`.claude/agents/security-reviewer.md`**: Least-privilege Android/iOS permissions, strict `https` URL scheme allowlisting on external deep links, sanitized `tel:` dialer inputs, and zero hardcoded secrets.
- **`.claude/agents/performance-optimizer.md`** & **`.claude/agents/dart-build-resolver.md`**: Monotonic async request tokens to prevent stale race conditions, bounded map marker counts, and automated CI verification (`flutter analyze` + `flutter test` + release `.apk`).
