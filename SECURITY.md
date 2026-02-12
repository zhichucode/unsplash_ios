# Security Policy

## Supported Versions

| Version | Supported |
|----------|------------|
| 1.0.x | ✅ |
| < 1.0 | ❌ |

## Reporting a Vulnerability

If you discover a security vulnerability, please **DO NOT** open a public issue.

Instead, please send an email to: [security@zhichucode.me](mailto:security@zhichucode.me)

Please include:

1. **Description** of the vulnerability
2. **Steps to reproduce** the issue
3. **Potential impact** if exploited
4. **Suggested fix** (if known)

## Response Time

We will acknowledge receipt of your report within **48 hours** and provide a detailed response within:

- **Critical**: 48 hours
- **High**: 72 hours
- **Medium**: 1 week
- **Low**: 2 weeks

## Disclosure Policy

Once the vulnerability is verified:

1. We will work on a fix
2. You will be notified when the fix is deployed
3. We will coordinate the public disclosure with you

## Security Best Practices

### For Users

- **Keep the app updated** - Always use the latest version
- **Review permissions** - Only grant necessary permissions
- **Download from official sources** - App Store or official GitHub releases
- **Report suspicious activity** - Let us know if you notice anything unusual

### For Developers

- **Never commit sensitive data** - API keys, passwords, tokens
- **Use environment variables** - For secrets and configuration
- **Review dependencies** - Keep third-party libraries updated
- **Follow secure coding practices** - Input validation, encryption, etc.

## Security Features

This app includes:

- ✅ **No user data collection** - All data stays on device
- ✅ **Minimal permissions** - Only photo library access when needed
- ✅ **No analytics/tracking** - Privacy-first design
- ✅ **CodeQL scanning** - Automated security analysis
- ✅ **Dependency scanning** - Dependabot enabled
- ✅ **Secure networking** - HTTPS only

## Responsible Disclosure

We follow responsible disclosure principles:

1. **Private coordination** - Work with reporters to fix issues
2. **Timely fixes** - Prioritize security updates
3. **Transparent communication** - Inform users of risks
4. **Coordinated release** - Announce fixes when patches are available

## Security Audits

This project undergoes:

- **Automated scanning** - GitHub CodeQL on every PR
- **Dependency updates** - Automated via Dependabot
- **Manual reviews** - Security-focused code review

---

Thank you for helping keep the Unsplash iOS app secure! 🔒
