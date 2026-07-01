
## Deployment and Branching Rules
* **Push Notifications**: ALWAYS notify the user and ask for explicit confirmation before pushing any changes to either remote branch.
* **Deployment Pipeline**: First push to the `staging` remote (Kanishk-C/pharma_local). Once validated and deemed stable, push the complete changes to the `production` remote (ksnsddhvn/pharma_local) and update the release APKs.

## Documentation Rules
* **Changelog**: ALWAYS update `CHANGELOG.md` after every set of changes and improvements, before committing. Group changes under the appropriate version heading using Keep a Changelog format (Added, Changed, Fixed, Removed).
