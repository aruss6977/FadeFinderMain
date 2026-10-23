# FadeFinderMain
FadeFinder Mobile Computing app main branch

## Username sign in

New accounts sign in with their username and password. Usernames are 3–24
letters, numbers, or underscores and are case insensitive. Firebase Auth uses
`<lowercase-username>@accounts.fadefinder.example` as an internal identifier;
the email entered during registration is saved in `users/<uid>.email` as contact
information. The separate fighter name is saved in `users/<uid>.fighterName`
and appears on the profile card; the username is used for sign in. This lets
different usernames share a contact email. Firebase's
built-in password reset emails cannot reach the internal address, so password
recovery needs a separate implementation before it is offered to users.

Accounts made before this change used the contact email as their Firebase Auth
identifier. On the sign in page, choose **Older account? Sign in with email**
for those accounts. Neither sign in path reads Firestore, so profile security
rules can remain private. To let an older account use username sign in, migrate
its Firebase Auth email to its internal username identifier with the Firebase
Admin SDK, keeping the same UID and contact email in the Firestore profile.
Check for duplicate usernames before migration.

Firebase is currently configured for web only in `lib/firebase_options.dart`.
