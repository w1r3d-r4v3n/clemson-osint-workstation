# Audit and governance

## Purpose and limits

The managed workstation makes assigned research reviewable without covert surveillance. It is not employee-monitoring software and must not be used for unrelated personal activity.

The technical record covers:

- case ID, assigned operating-system user, UTC event time, and case action;
- source hostname, evidence identifier, relative evidence path, byte count, and SHA-256;
- hash-chained case events and a signed receipt for every event;
- kernel audit records for execution of the case tool and Firefox, plus filesystem paths and write or attribute-change events under `~/Cases`;
- process-accounting records for executed program name, operating-system user, start time, elapsed time, and resource use, without command-line arguments;
- installed package versions, image version, audit public-key fingerprint, and encrypted-export recipient.

It intentionally does **not** collect passwords, cookies, form values, keystrokes, private-message contents, evidence contents, or unrelated personal browsing. Full source URLs remain inside the student's private case and encrypted submission, not in the minimized event details.

## Roles

- **Instructor administrator:** holds the VM administrator credential, the separate age decryption key, the workstation registration ledger, and authorization to review kernel audit logs.
- **Student analyst:** receives a unique standard account without `sudo`, performs only assigned public-source work, and can request signed receipts solely through the fixed audit helper.
- **Club leadership reviewer:** receives access only when named in the course notice or incident process and only for the documented purpose.

Never share administrator credentials, age private keys, or accounts. Do not install the instructor's age private key in a student VM.

## Before issuing a VM

Record in an instructor-controlled ledger:

1. student and course/club assignment ID;
2. VM name and clean snapshot identifier;
3. toolkit version and commit;
4. SHA-256 of `/opt/clemson-osint/install-manifest.txt`;
5. SHA-256 of `/opt/clemson-osint/audit-public.pem`;
6. instructor age recipient;
7. issue date, submission deadline, and deletion date.

Give the student a written notice containing the same audit scope, authorized reviewers, incident triggers, retention period, and appeal/contact path. Obtain the acknowledgement Clemson policy requires before use.

## Verifying a submission

The student submits the `.zip.age` file and adjacent `.sha256` through the Clemson-approved access-controlled channel. The instructor:

```bash
sha256sum -c CASE.zip.age.sha256
age --decrypt -i instructor-age-key.txt -o CASE.zip CASE.zip.age
unzip CASE.zip
osint-audit-verify PATH/TO/EXTRACTED/CASE
```

Compare the packaged `audit-public.pem` fingerprint with the pre-registered value. A valid signature proves that the registered workstation anchor accepted that event sequence. It does not prove that a source was truthful or that activity outside the managed workflow did not occur.

For a policy review or incident, the instructor may inspect the VM's root-owned audit trail:

```bash
sudo ausearch -k clemson_osint_cases
sudo ausearch -k clemson_osint_tools
sudo ausearch -k clemson_osint_browser
sudo less /var/log/clemson-osint/anchors.jsonl
sudo lastcomm --user osint-student
```

Do not export more audit data than the review requires. Never publish raw audit logs.

## Retention and deletion

Set a course-specific period before collection. A defensible default is deletion after grading and any appeal window, unless Clemson policy or a documented incident hold requires longer. At the deadline, delete instructor submissions, registration rows no longer required, VM copies, snapshots containing student work, and backups under the applicable Clemson process. Record completion without retaining the deleted case content.

## What this cannot guarantee

No local student workstation can guarantee complete attribution if the student has administrator access, can boot another operating system, controls the host, or uses an external device. The managed design therefore depends on a non-admin student account, a protected instructor credential, a known-good snapshot, transparent rules, and—if stronger network attribution is required—a separately approved institutional egress control. Do not market NAT or the audit receipts as anonymity protection or omniscient monitoring.
