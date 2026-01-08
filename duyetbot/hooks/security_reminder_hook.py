#!/usr/bin/env python3
"""
Security Reminder Hook - Checks for common security issues in code changes.
Skips checking .github/workflow/ YAML files.
"""

import sys
import json
import re
from pathlib import Path


def should_skip_file(file_path: str) -> bool:
    """Check if file should be skipped from security checks."""
    # Skip .github/workflow/ YAML files
    if ".github/workflow" in file_path or ".github/workflows" in file_path:
        return True
    return False


def check_security_issues(content: str, file_path: str) -> list:
    """Check content for common security issues."""
    issues = []

    # Skip if file should be ignored
    if should_skip_file(file_path):
        return issues

    lines = content.split('\n')

    # Check for hardcoded credentials/secrets
    secret_patterns = [
        (r'password\s*=\s*["\']([^"\']+)["\']', 'Hardcoded password detected'),
        (r'api[_-]?key\s*=\s*["\']([^"\']+)["\']', 'Hardcoded API key detected'),
        (r'secret\s*=\s*["\']([^"\']+)["\']', 'Hardcoded secret detected'),
        (r'token\s*=\s*["\']([^"\']+)["\']', 'Hardcoded token detected'),
    ]

    for line_num, line in enumerate(lines, 1):
        for pattern, message in secret_patterns:
            if re.search(pattern, line, re.IGNORECASE):
                issues.append({
                    "file": file_path,
                    "line": line_num,
                    "severity": "high",
                    "message": message,
                    "type": "secret"
                })

        # Check for SQL injection vulnerabilities
        if re.search(r'query\s*=\s*f["\'].*{.*}.*["\']', line, re.IGNORECASE):
            issues.append({
                "file": file_path,
                "line": line_num,
                "severity": "high",
                "message": "Potential SQL injection vulnerability with f-string",
                "type": "sql_injection"
            })

        # Check for unsafe eval
        if re.search(r'eval\s*\(', line):
            issues.append({
                "file": file_path,
                "line": line_num,
                "severity": "critical",
                "message": "Use of eval() is dangerous",
                "type": "unsafe_eval"
            })

        # Check for exec
        if re.search(r'exec\s*\(', line):
            issues.append({
                "file": file_path,
                "line": line_num,
                "severity": "critical",
                "message": "Use of exec() is dangerous",
                "type": "unsafe_exec"
            })

    return issues


def main():
    """Main hook entry point."""
    # Read input from stdin or command line arguments
    input_data = sys.stdin.read() if not sys.stdin.isatty() else json.dumps({})

    try:
        data = json.loads(input_data) if input_data else {}
    except json.JSONDecodeError:
        data = {}

    # Get file path and content from environment or arguments
    file_path = data.get("file_path", sys.argv[1] if len(sys.argv) > 1 else "")
    content = data.get("content", sys.argv[2] if len(sys.argv) > 2 else "")

    if not file_path or not content:
        sys.exit(0)

    # Check for security issues
    issues = check_security_issues(content, file_path)

    # Output findings
    if issues:
        print(json.dumps({
            "status": "warning",
            "issues": issues,
            "file": file_path
        }, indent=2))
        sys.exit(1)
    else:
        print(json.dumps({
            "status": "ok",
            "file": file_path
        }, indent=2))
        sys.exit(0)


if __name__ == "__main__":
    main()
