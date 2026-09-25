# Contributing

Contributions that improve reproducibility, accessibility, source quality, student safety, and maintainability are welcome.

## Before opening a pull request

1. Do not include case evidence, personal data, credentials, cookies, API keys, or details about a research subject.
2. Use synthetic or reserved-domain examples in tests and documentation.
3. Cite primary upstream documentation for package, command, licensing, or policy changes.
4. Keep active collection, exploitation, credential testing, and access-control bypass outside this repository.
5. Run the checks below.

```bash
bash -n install.sh bin/osint-doctor bin/osint-portal
python3 -m py_compile bin/osint-case tests/test_case_workflow.py tests/test_portal.py
python3 -m json.tool firefox-policies.json >/dev/null
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

Windows contributors should also parse both scripts under `windows/` with PowerShell or allow CI to do so.

## Pull request scope

Prefer one coherent change per pull request. Explain the student use case, safety implications, upstream source, tests run, and any migration required. New online services must disclose whether submissions become public, whether an account or payment is required, and which data is transmitted.

## Conduct

Be precise, respectful, and evidence-led. Do not use project spaces to expose personal data, accuse identifiable people, coordinate investigations of private individuals, or request help bypassing a service's controls.
