# How to make a new release (maintainer info)

## Release schedule

The xPack Windows Build Tools has no strict release schedule, but
will try to follow the GNU make release schedule, if possible.

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

- switch to the `xpack-develop` branch
- if needed, merge the `xpack` branch

### Increase the version

Determine the version (like `4.2.1`) and update the `scripts/VERSION`
file; the format is `4.2.1-1`. The fourth number is the xPack release number
of this version. A fifth number will be added when publishing
the package on the `npm` server.

### Fix possible open issues

Check GitHub issues and pull requests:

- https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues

and fix them; assign them to a milestone (like `4.2.1-1`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific file (below).

- update version in README-RELEASE.md
- update version in README-BUILD.md

## Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _v4.2.1-1 prepared_
- commit commit with a message like _CHANGELOG: prepare v4.2.1-1_

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Update the version specific code

- open the `common-versions-source.sh` file
- add a new `if` with the new version before the existing code

### Update helper

With Sourcetree, go to the helper repo and update to the latest master commit.

## Build

### Development run the build scripts

Before the real build, run a test build on the development machine (`wks`):

```sh
sudo rm -rf ~/Work/windows-build-tools-*

caffeinate bash ~/Downloads/windows-build-tools-xpack.git/scripts/build.sh --develop --without-pdf --disable-tests --all
```

Work on the scripts until all platforms pass the build.

## Push the build script

In this Git repo:

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

From here it'll be cloned on the production machines.

### Run the build scripts

Open a ssh session to the Linux machine `xbbi`:

```sh
caffeinate ssh xbbi
```

Clone the `xpack-develop` branch:

```sh
rm -rf ~/Downloads/windows-build-tools-xpack.git; \
git clone \
  --recurse-submodules \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/windows-build-tools-xpack.git \
  ~/Downloads/windows-build-tools-xpack.git
```

Remove any previous build:

```sh
sudo rm -rf ~/Work/windows-build-tools-*
```

Empty trash.

```sh
bash ~/Downloads/windows-build-tools-xpack.git/scripts/build.sh --all
```

A typical run takes about 2 minutes.

### Clean the destination folder

On the development machine (`wks`) clear the folder where binaries from all
build machines will be collected.

```sh
rm -f ~/Downloads/xpack-binaries/windows-build-tools/*
```

### Copy the binaries to the development machine

On `xbbi`:

```sh
(cd ~/Work/windows-build-tools-*/deploy; scp * ilg@wks:Downloads/xpack-binaries/windows-build-tools)
```

## Testing

Install the binaries on all supported platforms and check if they are
functional.

## Create a new GitHub pre-release

- in `CHANGELOG.md`, add release date
- commit and push the `xpack-develop` branch
- go to the GitHub [releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases) page
- click **Draft a new release**, in the `xpack-develop` branch
- name the tag like **v4.2.1-1** (mind the dash in the middle!)
- name the release like **xPack Windows Build Tools v4.2.1-1**
(mind the dash)
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/windows-build-tools-xpack/v4.2.1-1/total.svg)`
  - draft a short paragraph explaining what are the main changes, like
  _Version v4.2.1-1 is a new release of the **xPack Windows Build Tools** package, following the Windows Build Tools release._
  - add _For the moment these binaries are provided only for testing purposes!_
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients
watching this project.

## Run the release Travis tests

Using the scripts in `tests/scripts/`, start:

- `trigger-travis-quick.mac.command` (optional)
- `trigger-travis-stable.mac.command`
- `trigger-travis-latest.mac.command`

The test results are available from:

- https://travis-ci.org/github/xpack-dev-tools/windows-build-tools-xpack

For more details, see `tests/scripts/README.md`.

## Prepare a new blog post

In the `xpack/web-jekyll` GitHub repo:

- select the `develop` branch
- add a new file to `_posts/windows-build-tools/releases`
- name the file like `2020-12-27-windows-build-tools-v4-2-1-1-released.md`
- name the post like: **xPack Windows Build Tools v4.2.1-1 released**
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/tag/v4.2.1-1/`
- update the `date:` field with the current date
- update the Travis URLs using the actual test pages
- update the SHA sums via copy/paste from the original build machines
(it is very important to use the originals!)

If any, refer to closed
[issues](https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues)
as:

- **[Issue:\[#1\]\(...\)]**.

### Update the SHA sums

On the development machine (`wks`):

```sh
cat ~/Downloads/xpack-binaries/windows-build-tools/*.sha
```

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

501366492cd73b06fca98b8283f65b53833622995c6e44760eda8f4483648525
xpack-windows-build-tools-4.2.1-1-win32-ia32.zip

dffc858d64be5539410aa6d3f3515c6de751cd295c99217091f5ccec79cabf39
xpack-windows-build-tools-4.2.1-1-win32-x64.zip
```

## Update the preview Web

- commit the `develop` branch of `xpack/web-jekyll` GitHub repo;
  use a message like **xPack Windows Build Tools v4.2.1-1 released**
- wait for the GitHub Pages build to complete
- the preview web is https://xpack.github.io/web-preview/

## Update package.json binaries

- select the `xpack-develop` branch
- run `xpm-dev binaries-update`

```
cd ~/Downloads/windows-build-tools-xpack.git
xpm-js.git/bin/xpm-dev.js binaries-update '4.2.1-1' "${HOME}/Downloads/xpack-binaries/windows-build-tools"
```

- open the GitHub [releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases)
  page and select the latest release
- check the download counter, it should match the number of tests
- check the `baseUrl:` it should match the file URLs (including the tag/version);
  no terminating `/` is required
- from the release, check the SHA & file names
- compare the SHA sums with those shown by `cat *.sha`
- check the executable names
- commit all changes, use a message like
  `package.json: update urls for 4.2.1-1 release` (without `v`)

## Publish on the npmjs.com server

- select the `xpack-develop` branch
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v4.2.1-1.1_
- `npm version 4.2.1-1.1`; the first 4 numbers are the same as the
  GitHub release; the fifth number is the npm specific version
- `npm pack` and check the content of the archive, which should list
  only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`
- push the `xpack-develop` branch to GitHub
- `npm publish --tag next` (use `--access public` when publishing for
  the first time)

The version is visible at:

- https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools?activeTab=versions

## Test if the npm binaries can be installed with xpm

Install manually on both Windows 64/32-bit, .

```sh
xpm install --global @xpack-dev-tools/windows-build-tools@next
```

## Test the npm binaries

Install the binaries on all platforms.

```sh
xpm install --global @xpack-dev-tools/windows-build-tools@next
```

```
%USERPROFILE%\AppData\Roaming\xPacks\@xpack-dev-tools\windows-build-tools\4.2.1-1.1\.content\bin\make --version

GNU Make 4.2.1
```

## Update the repo

- merge `xpack-develop` into `xpack`
- push

## Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`
- `npm dist-tag add @xpack-dev-tools/windows-build-tools@4.2.1-1.1 latest`
- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`

## Update the Web

- in the `master` branch, merge the `develop` branch
- wait for the GitHub Pages build to complete
- the result is in https://xpack.github.io/news/
- remember the post URL, since it must be updated in the release page

## Create the final GitHub release

- go to the GitHub [releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack Windows Build Tools v4.2.1-1 released**
- paste the link to the Web page
  [release](https://xpack.github.io/windows-build-tools/releases/)
- click the **Tweet** button
