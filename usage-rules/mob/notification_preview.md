# notification_preview (mob)

**Documentation:** https://mishka.tools/chelekom/docs/mob/notification-preview

The way an app **previews a push** on the page that configures it: an app mark, an
`APP · time` line, a title and a body. See [README](README.md) for the shared rules.

## Generate
`mix mishka.ui.gen.mob notification_preview` → `lib/<app>/components/notification_preview.ex`,
tag `<NotificationPreview />` (`<MishkaNotificationPreview />` with `--module-prefix mishka_`).

## It previews; it never sends

There is no delivery and no permission read. Take the four strings and an icon and draw them;
the app that wants to arm the notification does that itself.

## Two layouts

`layout={:inline}` (default) is the phone's shade: the mark beside the text.
`layout={:stacked}` is the settings page: the mark and the app line on one row above the title.

## Headless

`background`, `corner_radius`, `padding`, every text size and colour, `app_font`,
`line_gap`, `body_gap` and `icon_gap` are props. Nothing is styled for you.
