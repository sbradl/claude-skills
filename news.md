# News

What changed in each version of the skills. Newest first.

## 0.2

Sharper TDD discipline.

- The green phase now checks that everything it added is actually run by a
  test — unused lines and branches get reverted instead of shipped.
- Every construct in a green change must trace to a failing assertion. Faking
  a value to pass is allowed; the next test is what forces it to generalise.
- A faked value is pinned down on the following slice, and a behaviour
  boundary always gets two slices, one on each side.
- When mutation testing finds a survivor in batch code, the fix goes into the
  loop rather than a one-off patch.
- The refactor phase will no longer add new behaviour, even when it looks
  necessary.

## 0.1

First release.

- **TDD loop** — builds a feature one behaviour at a time in batches of five,
  each batch closed by a refactor pass and a mutation-testing pass, pausing
  for your review. Red, green, and refactor each run in isolation so no
  imagined implementation leaks between phases.
- **Red / green / refactor** phases usable on their own: write one failing
  test, make it pass with the smallest change, or improve a design without
  touching behaviour.
- **Craft review** — reviews a change through five independent lenses
  (Domain-Driven Design, Code Smells, Clean Code, Pragmatic Programmer,
  Philosophy of Software Design), reported separately with no lens overriding
  another. Its findings drive the TDD loop's refactor pass.
