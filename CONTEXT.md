# Wrong Question Notebook (WQN)

WQN is a web application that helps students track, organise, and revise the problems they answered incorrectly. It turns a physical error log into an interactive system of notebooks, problems, review sessions, and AI-assisted insight.

## Language

### Core objects

**Notebook**:
A colour-coded, icon-labelled collection that organises a student's problems by topic (Mathematics, Physics, …).
_Avoid_: Subject — the product has moved to "notebook"; "subject" survives only as the legacy name in code, database, and some UI strings.

**Notebook Shelf**:
The student's home view showing all of their notebooks, each with its problem count and review-due summary.
_Avoid_: Dashboard, subject list.

**Problem**:
A single recorded question the student is practising or got wrong, with content, a type, a mastery status, and optionally an answer configuration and solution.
_Avoid_: Question, exercise (when referring to the stored record).

**Problem Type**:
The kind of question a problem is — Multiple Choice (MCQ), Short Answer, or Extended Response.
_Avoid_: Q-type, question kind.

**Tag**:
A keyword label, scoped to a notebook, attached to problems for fine-grained categorisation and filtering.

**Answer Configuration**:
How a problem's correct answer is expressed — a choice (MCQ), a list of acceptable short texts, or a numeric value with a tolerance and optional unit.
_Avoid_: Correct answer (when you mean the config, not the stored value).

**Mastery Status**:
The lifecycle state of a problem: Wrong → Needs Review → Mastered.
_Avoid_: Status, progress (alone, both are ambiguous).

**Attempt**:
A single recorded answer submission with its outcome and, when self-assessed, the student's own judgment of how it went.
_Avoid_: Submission, response (when referring to the saved record).

**Error Cause**:
Why the student got a problem wrong — conceptual misunderstanding, procedural error, knowledge gap, misread the question, careless mistake, ran out of time, or incomplete answer.
_Avoid_: Reason, mistake type, category.

### Review

**Review Session**:
A structured, pausable run through a set of problems during which the student submits attempts. A session is Normal, Spaced Repetition, or Insights Review.
_Avoid_: Practice mode (practice mode is the untracked preview variant, not a session).

**Spaced Repetition**:
Scheduling each problem's next review at growing intervals based on how it was answered, so due problems resurface at the right time.
_Avoid_: SRS (internal only), revision plan.

**Insights Review**:
A review session assembled from a student's identified weak spots to target specific error patterns.
_Avoid_: Smart review, weakness drill.

### Sharing & community

**Problem Set**:
A named group of problems assembled for focused review, which can be shared with others.
_Avoid_: Set, deck (when alone, ambiguous).

**Manual Set**:
A problem set whose membership is chosen problem by problem.

**Smart Set**:
A problem set whose membership is auto-populated from saved filter criteria instead of being picked by hand.
_Avoid_: Auto set, dynamic set.

**Filter Criteria**:
A reusable spec (tags, statuses, problem types, review-date window) that powers faceted search, Smart Sets, and Smart Set membership.
_Avoid_: Smart filter, query (alone).

**Sharing Level**:
How a problem set is exposed — Private, Limited (shared with specific people by email), or Public (anyone with the link).
_Avoid_: Visibility (reserved for the listed/unlisted toggle).

**Listed**:
The state of a public set being opted into Discovery with a subject category. A public set can be unlisted (direct link only) and a listed set is always public.
_Avoid_: Published, discoverable.

**Discovery**:
The public browsing surface where students search, filter, and rank listed sets from other students.
_Avoid_: Explore, gallery.

**Creator**:
A student who lists public sets and therefore has a public profile page with their engagement stats and listed sets.

**Engagement**:
The public social signals on a listed set — views (bounce-filtered), likes, favourites, copies, and reports. Favourites are the student's own saves; likes are public appreciation.
_Avoid_: Metrics, stats (when referring to the per-set signals).

### AI assistance

**AI Extraction**:
Turning a photo of a problem into a structured problem draft — detecting its type, choices, and likely answer — that the student reviews before saving.
_Avoid_: OCR, scanning (extraction includes structure, not just text).

**Insight Digest**:
An AI-generated periodic report of the student's error patterns, weak spots, and topic clusters, produced from their attempts and error causes.
_Avoid_: Insights (plural alone), report (generic).

### Transfer

**QR Transfer**:
Handing a problem photo from the student's phone to their desktop by scanning a QR code into a short-lived session, from which the image can be saved or extracted.
_Avoid_: Upload link, phone sync.
