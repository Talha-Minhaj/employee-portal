# Employee Portal — Onboarding Guide

Welcome! This is a SAP CAP (Node.js) + Fiori Elements app deployed to SAP BTP Cloud Foundry. This guide gets you productive locally and — more importantly — captures the **deployment lessons we learned the hard way**, so you don't relearn them.

## Project at a glance

- **Stack:** SAP CAP (`@sap/cds` 8) · OData V4 · Fiori Elements (List Report/Object Page) · SQLite locally / SAP HANA Cloud in production · App Router + XSUAA
- **Repo:** https://github.com/Talha-Minhaj/employee-portal
- **Live app:** https://ecd75d70trial-dev-employee-portal.cfapps.us10-003.hana.ondemand.com/index.html (BTP trial, org `ecd75d70trial`, space `dev`, region `us10-003`)
- **Full architecture & feature docs:** see [README.md](README.md)

## Local development

```bash
npm install        # pure-JS install; no C++ toolchain needed (see "Toolchain notes")
npx cds deploy     # creates + seeds db.sqlite (schema, sample data, draft tables)
npm start          # local cds-serve on http://localhost:4004
```

- Mock users (basic auth): `alice`/`alice` (employee, no roles) · `bob`/`bob` (Manager — can approve/decline).
- Fiori preview (dev only): `http://localhost:4004/$fiori-preview/EmployeeService/Requests#preview-app`
- After changing `db/schema.cds` or seed CSVs, re-run `npx cds deploy` (drops/recreates tables).
- The **production** UI lives in `app/router/resources/` and is served by the App Router — the `$fiori-preview` is not deployed.

## Toolchain notes (Windows)

- **Node 24 + `better-sqlite3`:** pinned to `12.11.1` via npm `overrides` so a prebuilt binary is used — do not remove the override unless the VS C++ workload is installed.
- **`@sap/cds-dk` is a local devDependency** (v8, matching `@sap/cds` 8). The globally installed cds-dk v10 is incompatible — always use `npx cds ...` in this repo.
- **Build/deploy tools:** `mbt` (npm -g), GNU Make 4.4.1 (winget `ezwinports.make`), cf CLI v8 + `multiapps` plugin (winget `CloudFoundry.CLI.v8`). After installing via winget, **open a fresh terminal** so PATH updates apply.

## Deploying to BTP — the learnings that matter

### 1. Bump the MTA version on EVERY deploy
With an unchanged `version:` in `mta.yaml`, the MultiApps deployer may decide a module's content is unchanged and log:

```
Content of application "employee-portal" is not changed - upload will be skipped.
```

…which **silently keeps stale code live** even though your `.mtar` uploaded. Always bump `version:` (currently `1.0.2`) and confirm the deploy log shows `Uploading application "..."` + `Staging` for the module you changed.

### 2. Start HANA before deploying (trial auto-stops it)
BTP trial stops SAP HANA Cloud overnight/on idle. If it's down, the `db-deployer` task fails with `HANA Database instance is stopped` (and retries 3× before giving up). **BTP Cockpit → SAP HANA Cloud → Start**, wait for green, then deploy. Trial also auto-stops CF apps — `cf start employee-portal employee-portal-srv` after idle periods.

### 3. Stop the local dev server before `mbt build`
The build runs `npm ci`, which must delete `node_modules` — a running `npm start` holds a lock on `better_sqlite3.node` and the build dies with `EPERM`. Kill anything on port 4004 first.

### 4. Hard-refresh after every redeploy
The App Router serves static UI files with caching. After a deploy, a normal reload can show the **old** (possibly broken) UI — always **Ctrl+Shift+R**. This masked two fixes during development.

### 5. XSUAA login needs redirect-uris
`xs-security.json` must contain:

```json
"oauth2-configuration": { "redirect-uris": ["https://*.cfapps.us10-003.hana.ondemand.com/**"] }
```

Without it, login fails with *"the request for authorization was invalid"*. Approve/Decline additionally requires the **`EmployeePortalManager`** role collection assigned to your user in the BTP cockpit.

### 6. `cf deploy` takes a file path, not a URL or app name

```bash
cf login -a https://api.cf.us10-003.hana.ondemand.com --sso   # manual — needs your credentials
cf deploy mta_archives/employee-portal_<version>.mtar
```

Useful when things go wrong: `cf dmol -i <operation-id>` downloads deployer logs (the `mta-op-*/` output is git-ignored).

## UI gotchas (already fixed — don't reintroduce)

- **Fiori Elements manifest routing:** keep `"routing": { "config": {} }`. Adding FCL-style config (`controlId: "fcl"`) without an FCL root view makes the app boot into a **silent blank page**.
- **Height chain in `index.html`:** UI5 **strips the `data-sap-ui-component` attribute at boot**, so CSS keyed on it stops applying and the app renders 0px tall (fully functional, invisible). The wrapper div has a permanent `id="appContainer"` and the style block pins `html/body/#appContainer/...` to `height: 100%`. Keep both.

## Debugging a "blank page" checklist

1. F12 → Console — one fatal line (like `Control with ID fcl could not be found`) beats guessing; most red UI5 lines (`Component-preload.js` 404, `i18n_en` 404, `lrep/flex` 404) are harmless noise.
2. Run in console: `document.querySelector('.sapUiComponentContainer').offsetHeight` — if `0` but text exists in `document.body.innerText`, it's a height/CSS issue, not a data issue.
3. Network tab → `$batch` status: 200 = data flowing; 401/403 = auth; 404 = routing.
4. Confirm which archive version is actually deployed before debugging code (`cf mta employee-portal`).
