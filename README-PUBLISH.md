# How to publish the xPack Windows Build Tools binaries

## Build

Before starting the build, perform some checks.

### Check possible open issues

Check GitHub [issues](https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues)
and fix them; do not close them yet.

### Check the CHANGELOG file

Open the `CHANGELOG.txt` file from `xpack-dev-tools/windows-build-tools-xpack.git`
and check if all new entries are in.

Note: if you missed to update the `CHANGELOG.txt` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Check the version

The `VERSION` file should refer to the actual release.

### Push the build scripts

In this Git repo:

- if necessary, merge the `xpack-develop` branch into `xpack`.
- push it to GitHub.
- possibly push the helper project too.

### Run the build scripts

When everything is ready, follow the instructions on the
[build](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/master/README.md)
page.

## Test

Install the binaries on all supported platforms and check if they are
functional.

## Create a new GitHub pre-release

- in `CHANGELOG.md`, add release date
- commit and push the repo
- go to the [GitHub Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases) page
- click **Draft a new release**
- name the tag like **v2.12.2**
- select the `master` branch
- name the release like **xPack Windows Build Tools v2.12.2**
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/windows-build-tools-xpack/v2.12.2/total.svg)`
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients
watching this project.

## Prepare a new blog post

In the `xpack.github.io` web Git:

- add a new file to `_posts/windows-build-tools/releases`
- name the file like `2020-07-14-windows-build-tools-v2-12-2-released.md`
- name the post like: **xPack Windows Build Tools v2.12.2 released**
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/tag/v2.12.2/`
- update the `date:` field with the current date

If any, close [issues](https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues)
on the way. Refer to them as:

- **[Issue:\[#22\]\(...\)]**.

## Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

96a796420ae47f5ef0e85af99be40ce28ed960f515121ad9b7ce4264a4765822
xpack-windows-build-tools-2.12.2-win32-x32.zip

54e443420bfe355e7d0b0f3e896eed311847c02fab1fee6e8db89a474987a9a2
xpack-windows-build-tools-2.12.2-win32-x64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd deploy
$ cat *.sha
```

## Update the web

- commit the `xpack.github.io` web Git; use a message
  like **xPack Windows Build Tools v2.12.2 released**
- adjust timestamps
- push the project
- wait for the GitHub Pages build to complete
- remember the post URL, since it must be updated in the release page

## Publish on the npmjs.com server

- open [GitHub Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases)
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- check the executable names
- commit all changes, use a message like `package.json: update urls for 2.12.2 release` (without `v`)
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v2.12.2-2_
- `npm version 2.12.2-2`; the first 3 numbers are the same as the
  GitHub release; the fourth number is the npm specific version
- `npm pack` and check the content of the archive
- push all changes to GitHub
- `npm publish --tag next` (use `--access public` when publishing for the first time)

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`
- `npm dist-tag add @xpack-dev-tools/windows-build-tools@2.12.2-2 latest`
- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`

## Test npm binaries

Install the binaries on all platforms.

```console
$ xpm install --global @xpack-dev-tools/windows-build-tools@next
```

## Create a final GitHub release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- go to the new post and follow the Tweet link
- copy the content to the clipboard
- DO NOT click the Tweet button here, it'll not use the right account
- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account, paste the content
- click the Tweet button
