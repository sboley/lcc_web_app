# Lake City Creamery web app

The Flutter website reads its public flavor and hours data from MongoDB through
the API in `server/`. Admin flavor edits require a short-lived API token; the
MongoDB URI and admin credentials belong only in server environment variables.

## Deploy the API

1. Create a MongoDB Atlas database and a Railway service using `server/` as the
   service root directory. Railway should run `npm start`.
2. Set these Railway variables:
   - `MONGODB_URI`: the Atlas connection string.
   - `MONGODB_DB`: database name (optional; defaults to `lcc`).
   - `ADMIN_USERNAME`: the admin login name.
   - `ADMIN_PASSWORD`: a unique password of at least 12 characters.
   - `JWT_SECRET`: a random secret of at least 32 characters.
   - `ALLOWED_ORIGINS`: comma-separated exact production website origins, with
     no trailing slash.
   - `PORT`: supplied automatically by Railway.
3. Allow the Railway service to connect to the Atlas cluster using the network
   access configuration appropriate for your Railway plan.

On its first start, the API inserts `server/seed-data.json` only if the menu
document does not exist. This file is initialized with the current published
hours and flavors. Later deploys do not overwrite admin changes. To initialize
or check the seed manually, run `npm run seed` from `server/`.

## Deploy the Flutter website

The Railway API URL is the app's default, so build and deploy the web app as
usual:

```sh
flutter build web --release
```

Deploy the resulting `build/web` directory using the existing Cloudflare Pages
setup. Set `ALLOWED_ORIGINS` on Railway to the exact Cloudflare site origin,
such as `https://www.example.com`. For local development, run the API from
`server/` with a local `.env` based on `.env.example`, then build/run Flutter
with `--dart-define=API_BASE_URL=http://localhost:3000` if using a local API.
Allow the local Flutter web origin in `ALLOWED_ORIGINS` when calling Railway
from a local browser.

## Admin

Open the site's drawer and choose **Admin**. Sign in with the Railway admin
credentials and edit the flavor list (one flavor or section heading per line).
Hours are served from MongoDB and are currently read-only in the website.
Admin sessions expire after two hours and are kept in memory by the browser.
