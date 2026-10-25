# flutter_html 3.0.0 — vendored with cached CSS selector parsing

The pub.dev release, unchanged except `lib/src/tree/styled_element.dart`
(`StyledElement.matches`), with the example, tests and melos workspace
removed.

Styling tests every selector in the `style:` map (and every `<style>` rule)
against every element. `matches` called the html package's
`matches(element, String selector)`, which parses the selector text with
csslib on every call. The dictionary page passes each dictionary's own
stylesheet, so a single entry cost elements × selectors parses: measured
on the phone (2026-10-25) as most of the 0.1–0.8 s it took to draw a
lookup's results. Selectors are now parsed once per process into a static
cache; a selector that fails to parse or to evaluate still matches nothing,
as before.

Drop this copy if upstream caches parsed selectors.
