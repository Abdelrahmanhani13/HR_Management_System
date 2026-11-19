# hrmsapp

A new Flutter project.

## Supabase authentication

This is an invite-only HR system. Create accounts through the Supabase
administrator workflow; there is no public signup in the app. The client
supports email/password sign-in, sign-out, session restore, and password
recovery. Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` in the local `.env`
file. For password recovery links, set `SUPABASE_AUTH_REDIRECT_URL` to a URI
configured in Supabase Auth's URL allow list and in the target platform's
deep-link settings. Assign roles through a trusted administrator workflow.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
