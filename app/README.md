# Overheads App

## GitHub Pages deployment

This repository now includes a GitHub Actions workflow at `.github/workflows/deploy-pages.yml`.

To use it:

1. In GitHub, open Settings > Pages.
2. Set Source to GitHub Actions.
3. Push to `web` or `master`, or run the workflow manually from the Actions tab.

The workflow builds the Flutter web app from `app/`, publishes the generated site to GitHub Pages, and carries the repository `CNAME` file into the deployed artifact.
