# Fighter discovery from users

Account creation writes one document to `users/{uid}`, as it did before fighter
discovery was added. The account's contact email can be shared by multiple
profiles because sign-in uses an internal address derived from the unique
username.

Discover and Vote read documents from `users`, convert fighter details into
cards, and calculate each fighter's weight class from `weightLbs`. Email and
username are never placed on those cards. No new Firestore collection, field,
or rules file is needed for account creation.

The current Firestore rules must already allow signed-in users to query the
`users` collection for discovery to work. Successful account creation confirms
that the creator can write their own document; it does not prove that other
accounts can read it. The app cannot inspect the deployed rules locally.

Hiding email and username in the UI does not keep them private from a client
that can read `users` documents. Firestore returns the whole document. Keeping
those fields private at the database level would require moving them to a
separately protected document and publishing corresponding rules.
