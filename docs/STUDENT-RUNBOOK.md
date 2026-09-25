# Student runbook

## The rule

Use the least intrusive method that can answer the question. Public availability does not make every collection or publication ethical. Your instructor's scope and Clemson policies control the exercise.

## 1. Frame the question

Write one falsifiable question, the authority for the exercise, what is in and out of scope, and when you will stop. Do not begin with a conclusion you intend to prove.

Create the case:

```bash
osint-case new "Lab 01 - public claim" --purpose "Course exercise; public sources only"
osint-case list
```

Use the short ID shown by `list` in later commands.

## 2. Make a collection plan

Record known identifiers and distinguish them:

- Strong identifiers: official registration number, exact domain, cryptographic hash.
- Contextual identifiers: name plus employer, city plus date, username plus avatar.
- Weak identifiers: common name, visual resemblance, an uncorroborated username match.

Plan at least two independent source classes. Ten pages repeating one press release are one underlying source, not ten confirmations.

## 3. Discover broadly

Open `osint-portal`. Start with general search and authoritative records. Record useful pages as you go:

```bash
osint-case source CASE_ID "https://example.org/page" \
  --title "Page title" --category "official-record" \
  --notes "Why this may answer the question"
```

Treat username tools, search snippets, AI summaries, aggregators, and people-search sites as leads. Do not report them as identity proof.

## 4. Verify the claim

For each material claim, ask:

1. Identity: is this the same person, organization, account, place, or object?
2. Time: when was the underlying event, not merely the upload or crawl?
3. Location: what observable features support the location?
4. Context: is the item complete, original, and represented accurately?
5. Independence: do corroborating sources derive from different evidence?
6. Alternatives: what else could explain the observation?

Use confidence labels consistently: `confirmed`, `probable`, `possible`, `unresolved`, or `contradicted`. State the evidence threshold you used.

## 5. Preserve originals and provenance

Keep the original file unchanged. Work on a copy when cropping, transcoding, annotating, or extracting frames.

```bash
osint-case ingest CASE_ID ~/Downloads/report.pdf \
  --source "https://publisher.example/report.pdf" \
  --notes "Downloaded from publisher; original filename report.pdf"
osint-case verify CASE_ID
```

The ingest command copies the file into the case and records its SHA-256, size, UTC ingest time, source URL, and note. It does not prove the source is truthful; it lets another analyst verify that the file did not change after ingest.

Do not upload sensitive files to online metadata, OCR, translation, or malware-analysis sites without instructor approval. The workstation includes local equivalents for common tasks.

## 6. Analyze locally

Useful commands:

```bash
exiftool -a -G1 -s IMAGE.jpg
mediainfo VIDEO.mp4
ffprobe -hide_banner VIDEO.mp4
pdfinfo DOCUMENT.pdf
pdftotext -layout DOCUMENT.pdf -
sha256sum FILE
```

To extract one video frame every five seconds:

```bash
mkdir -p frames
ffmpeg -i VIDEO.mp4 -vf fps=1/5 frames/%04d.jpg
```

Record the command, tool version, and any interpretation that matters to the finding.

## 7. Write the report

The case `README.md` is the working report. A defensible finding contains:

- the scoped question;
- the direct observation;
- the source ID and access date;
- the inference, separately labeled;
- corroborating and conflicting evidence;
- confidence and why;
- limitations and a reasonable stopping point.

Minimize personal data in the final report. Include what is necessary to substantiate the finding, not everything collected.

## 8. Peer review and close

Have a peer check source independence, identity resolution, timestamps, alternative explanations, citations, and redactions. Then:

```bash
osint-case verify CASE_ID
osint-case close CASE_ID
```

Submit the ZIP and its `.sha256` file from the case `exports` folder. Keep the original case private until the retention date set by the instructor.

## Stop and ask the instructor when

- a source requires credentials, deception, payment, or bypassing a control;
- the work would contact or alert the subject;
- the work involves minors, medical data, intimate content, precise home location, or credible threats;
- you encounter leaked credentials, illegal content, or an active emergency;
- the next step would be active scanning, automation at scale, or an API whose terms you have not checked;
- you are unsure whether publishing the result could cause harm.
