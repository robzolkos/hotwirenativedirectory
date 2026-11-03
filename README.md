# Hotwire Native Directory

A place to discover Hotwire Native applications and share learnings on building them.

## Add your app

1. Append your app details to `_data/app_directory.yml`.
2. Add the app image that the YAML entry references to `assets/images/apps/`.
3. Create a PR.

Each entry needs a `name`, an `app_category`, an `image`, and an `ios_url` or `android_url`. The optional keys are `description`, `web_url`, and `source_url`. An `android_url` must link to Google Play or F-Droid. Leave out a key instead of setting it to an empty string.

See [this PR](https://github.com/robzolkos/turbonativedirectory/pull/79/files) for an example of how to add your own app to the directory. That PR uses the old Rails paths. The entry format is the same.

## Run the site locally

The site is a single Jekyll page with plain CSS and no build step for assets.

```sh
bundle install
bundle exec ruby test/app_directory_test.rb
bundle exec jekyll serve
```

Open http://localhost:4000. The test checks every entry in `_data/app_directory.yml`, and CI runs it on each PR.

## Edit the styles

Stylesheets live in `assets/stylesheets/`, one file per component, in the style of [Fizzy](https://github.com/basecamp/fizzy). The layout links every file in that folder in alphabetical order. `_global.css` sorts first. It declares the cascade layers (`reset`, `base`, `components`) and the shared custom properties. To add a component, create a new file and wrap its rules in `@layer components`.
