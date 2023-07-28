[![license](https://img.shields.io/github/license/xpack-dev-tools/windows-build-tools-xpack)](https://github.com/xpack-dev-tools/windows-build-tools-xpack/blob/xpack/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/xpack-dev-tools/windows-build-tools-xpack.svg)](https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues/)
[![GitHub pulls](https://img.shields.io/github/issues-pr/xpack-dev-tools/windows-build-tools-xpack.svg)](https://github.com/xpack-dev-tools/windows-build-tools-xpack/pulls)

# Maintainer info

## Prerequisites

The build scripts run on GNU/Linux and macOS. The Windows binaries are
generated on Intel GNU/Linux, using [mingw-w64](https://mingw-w64.org).

For GNU/Linux, the prerequisites are:

- `curl` (installed via the system package manager)
- `git` (installed via the system package manager)
- `docker` (preferably a recent one, installed from **docker.com**)
- `npm` (shipped with Node.js; installed via **nvm**, **not**
  the system package manager)
- `xpm` (installed via `npm`)

For macOS, the prerequisites are:

- `npm` (shipped with Node.js; installed via **nvm**)
- `xpm` (installed via `npm`)
- the **Command Line Tools** from Apple

For details on installing them, please read the
[XBB prerequisites](https://xpack.github.io/xbb/prerequisites/) page.

If you already have a functional configuration from a previous run,
it is recommended to update **xpm**:

```sh
npm install --location=global xpm@latest
```

## Get project sources

The project is hosted on GitHub:

- <https://github.com/xpack-dev-tools/windows-build-tools-xpack.git>

To clone the stable branch (`xpack`), run the following commands in a
terminal (on Windows use the _Git Bash_ console):

```sh
rm -rf ~/Work/xpack-dev-tools/windows-build-tools-xpack.git && \
git clone https://github.com/xpack-dev-tools/windows-build-tools-xpack.git \
  ~/Work/xpack-dev-tools/windows-build-tools-xpack.git
```

For development purposes, clone the `xpack-develop` branch:

```sh
rm -rf ~/Work/xpack-dev-tools/windows-build-tools-xpack.git && \
mkdir -p ~/Work/xpack-dev-tools && \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/windows-build-tools-xpack.git \
  ~/Work/xpack-dev-tools/windows-build-tools-xpack.git
```

Or, if the repo was already cloned:

```sh
git -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git pull
```

## Get helper sources

The project has a dependency to a common **helper**; clone the
`xpack-develop` branch and link it to the central xPacks store:

```sh
rm -rf ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
mkdir -p ~/Work/xpack-dev-tools && \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/xbb-helper-xpack.git \
  ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
xpm link -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

Or, if the repos were already cloned:

```sh
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull
xpm link -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git
```

## Release schedule

The xPack Windows Build Tools has no strict release schedule, but
will try to follow the GNU make
[releases](https://ftp.gnu.org/gnu/make/).

However, make stables releases were rare, and occasionally git sources
might be used.

## How to make new releases

Before starting the build, perform some checks and tweaks.

### Download the build scripts

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/windows-build-tools-xpack`](https://github.com/xpack-dev-tools/windows-build-tools-xpack)
Git repo.

To download them on a new machine, clone the `xpack-develop` branch,
as seen above.

### Check Git

In the `xpack-dev-tools/windows-build-tools-xpack` Git repo:

- switch to the `xpack-develop` branch
- pull new changes
- if needed, merge the `xpack` branch

No need to add a tag here, it'll be added when the release is created.

### Check the latest upstream release

#### make

Check the latest release from
(<https://mirrors.nav.ro/gnu/make/>) and and compare with
the xPack [release](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases).
When using Git, check the latest commit from
[savannah](https://git.savannah.gnu.org/cgit/make.git/log/).

#### busybox

To identify the latest commits, check the GitHub tags
<https://github.com/rmyorston/busybox-w32/tags> and possibly the latest commits
<https://github.com/rmyorston/busybox-w32/commits/master>.

### Increase the version

Determine the version (like `4.4.0`) and update the `scripts/VERSION`
file; the format is `4.4.0-1`. The fourth number is the xPack release number
of this version. A fifth number will be added when publishing
the package on the `npm` server.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues/>

and fix them; assign them to a milestone (like `4.4.0-1`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-MAINTAINER.md`
- update version in `README.md`

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _* v4.4.0-1 prepared_
- commit with a message like _prepare v4.4.0-1_

### Update the version specific code

- open the `scripts/versioning.sh` file
- add a new `if` with the new version before the existing code

## Build

The builds currently run on a dedicated machine (Intel GNU/Linux).

### Development run the build scripts

Before the real build, run a test builds.

#### Visual Studio Code

All actions are defined as **xPack actions** and can be conveniently
triggered via the VS Code graphical interface, using the
[xPack extension](https://marketplace.visualstudio.com/items?itemName=ilg-vscode.xpack).

#### Intel GNU/Linux

Run the docker build on the production machine (`xbbli`);
start a VS Code remote session, or connect with a terminal:

```sh
caffeinate ssh xbbli
```

##### Build the Windows binaries

Update the build scripts (or clone them at the first use):

```sh
git -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git pull && \
xpm run install -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git && \
git -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git pull && \
xpm link -C ~/Work/xpack-dev-tools/xbb-helper-xpack.git && \
xpm run link-deps -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git && \
xpm run deep-clean --config linux-x64 -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git && \
xpm run docker-prepare --config linux-x64 -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git && \
xpm run docker-link-deps --config linux-x64 -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git
xpm run docker-build-develop --config linux-x64 -C ~/Work/xpack-dev-tools/windows-build-tools-xpack.git
```

Several minutes later, the output of the build script is a compressed
archive and its SHA signature, created in the `deploy` folder:

```console
$ ls -l ~/Work/xpack-dev-tools/windows-build-tools-xpack.git/build/win32-x64/deploy
total 2676
-rw-r--r-- 1 ilg ilg 2734882 Jan 29 16:32 xpack-windows-build-tools-4.4.0-1-win32-x64.zip
-rw-r--r-- 1 ilg ilg     114 Jan 29 16:32 xpack-windows-build-tools-4.4.0-1-win32-x64.zip.sha
```

### Files cache

The XBB build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
<https://github.com/xpack-dev-tools/files-cache/tree/master/libs>),
place them in the XBB cache (`Work/cache`) and restart the build.

## Run the CI build

The automation is provided by GitHub Actions and three self-hosted runners.

### Generate the GitHub workflows

Run the `generate-workflows` to re-generate the
GitHub workflow files; commit and push if necessary.

### Start the self-hosted runners

- on the development machine (`wksi`) open ssh sessions to the build
machine (`xbbli`):

```sh
caffeinate ssh xbbli
```

Start the runners:

```sh
screen -S ga

~/actions-runners/xpack-dev-tools/1/run.sh &
~/actions-runners/xpack-dev-tools/2/run.sh &
```

### Push the build scripts

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

From here it'll be cloned on the production machines.

### Check for disk space

Check if the build machines have enough free space and eventually
do some cleanups.

### Manually trigger the build GitHub Actions

To trigger the GitHub Actions build, use the xPack action:

- `trigger-workflow-build-xbbli`

This is equivalent to:

```sh
bash ~/Work/xpack-dev-tools/gcc-xpack.git/xpacks/xpack-dev-tools-xbb-helper/github-actions/trigger-workflow-build.sh --machine xbbli
```

These scripts require the `GITHUB_API_DISPATCH_TOKEN` variable to be present
in the environment, and the organization `PUBLISH_TOKEN` to be visible in the
Settings → Action →
[Secrets](https://github.com/xpack-dev-tools/windows-build-tools-xpack/settings/secrets/actions)
page.

This command uses the `xpack-develop` branch of this repo.

## Durations & results

The builds take a few minutes to complete.

The workflow result and logs are available from the
[Actions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/actions/) page.

The resulting binaries are available for testing from
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/).

## Testing

### CI tests

The automation is provided by GitHub Actions.

To trigger the GitHub Actions tests, use the xPack actions:

- `trigger-workflow-test-prime`

This is equivalent to:

```sh
bash ~/Work/xpack-dev-tools/windows-build-tools-xpack.git/xpacks/xpack-dev-tools-xbb-helper/github-actions/trigger-workflow-test-prime.sh
```

These scripts require the `GITHUB_API_DISPATCH_TOKEN` variable to be present
in the environment.

These actions use the `xpack-develop` branch of this repo and the
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/)
binaries.

The tests results are available from the
[Actions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/actions/) page.

### Manual tests

Install the binaries and check if they are
functional, possibly by running Eclipse builds.

## Create a new GitHub pre-release draft

- in `CHANGELOG.md`, add the release date and a message like _* v4.4.0-1 released_
- commit with _CHANGELOG update_
- check and possibly update the `templates/body-github-release-liquid.md`
- push the `xpack-develop` branch
- run the xPack action `trigger-workflow-publish-release`

The workflow result and logs are available from the
[Actions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/actions/) page.

The result is a
[draft pre-release](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/)
tagged like **v4.4.0-1** (mind the dash in the middle!) and
named like **xPack Windows Build Tools v4.4.0-1** (mind the dash),
with all binaries attached.

- edit the draft and attach it to the `xpack-develop` branch (important!)
- save the draft (do **not** publish yet!)

## Prepare a new blog post

- check and possibly update the `templates/body-jekyll-release-*-liquid.md`
- run the xPack action `generate-jekyll-post`; this will leave a file
on the Desktop.

In the `xpack/web-jekyll` GitHub repo:

- select the `develop` branch
- copy the new file to `_posts/releases/windows-build-tools`
- refer to the Busybox commit and date

If any, refer to closed
[issues](https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues/).

## Update the preview Web

- commit the `develop` branch of `xpack/web-jekyll` GitHub repo;
  use a message like _xPack Windows Build Tools v4.4.0-1 released_
- push to GitHub
- wait for the GitHub Pages build to complete
- the preview web is <https://xpack.github.io/web-preview/news/>

## Create the pre-release

- go to the GitHub [Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/) page
- perform the final edits and check if everything is fine
- temporarily fill in the _Continue Reading »_ with the URL of the
  web-preview release
- **keep the pre-release button enabled**
- do not enable Discussions yet
- publish the release

Note: at this moment the system should send a notification to all clients
watching this project.

## Update the READMEs listings and examples

- check and possibly update the `ls -l` output
- check and possibly update the output of the `--version` runs
- check and possibly update the output of `tree -L 2`
- commit changes

## Check the list of links

- open the `package.json` file
- check if the links in the `bin` property cover the actual binaries
- if necessary, also check on Windows

## Update package.json binaries

- select the `xpack-develop` branch
- run the xPack action `update-package-binaries`
- open the `package.json` file
- check the `baseUrl:` it should match the file URLs (including the tag/version);
  no terminating `/` is required
- from the release, check the SHA & file names
- compare the SHA sums with those shown by `cat *.sha`
- check the executable names
- commit all changes, use a message like
  _package.json: update urls for 4.4.0-1.1 release_ (without _v_)

## Publish on the npmjs.com server

- select the `xpack-develop` branch
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`, add a line like _* v4.4.0-1.1 published on npmjs.com_
- commit with a message like _CHANGELOG: publish npm v4.4.0-1.1_
- `npm pack` and check the content of the archive, which should list
  only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`;
  possibly adjust `.npmignore`
- `npm version 4.4.0-1.1`; the first 4 numbers are the same as the
  GitHub release; the fifth number is the npm specific version
- the commits and the tag should have been pushed by the `postversion` script;
  if not, push them with `git push origin --tags`
- `npm publish --tag next` (use `npm publish --access public`
  when publishing for the first time; add the `next` tag)

After a few moments the version will be visible at:

- <https://www.npmjs.com/package/@xpack-dev-tools/windows-build-tools?activeTab=versions>

## Test if the binaries can be installed with xpm

Run the xPack action `trigger-workflow-test-xpm`, this
will install the package via `xpm install` on all supported platforms.

The tests results are available from the
[Actions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/actions/) page.

## Update the repo

- merge `xpack-develop` into `xpack`
- push to GitHub

## Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`
- `npm dist-tag add @xpack-dev-tools/windows-build-tools@4.4.0-1.1 latest`
- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`

In case the previous version is not functional and needs to be unpublished:

- `npm unpublish @xpack-dev-tools/windows-build-tools@4.4.0-1.1`

## Update the Web

- in the `master` branch, merge the `develop` branch
- wait for the GitHub Pages build to complete
- the result is in <https://xpack.github.io/news/>
- remember the post URL, since it must be updated in the release page

## Create the final GitHub release

- go to the GitHub [Releases](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- remove the _tests only_ notice
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack Windows Build Tools v4.4.0-1 released**
- paste the link to the Web page
  [release](https://xpack.github.io/windows-build-tools/releases/)
- click the **Tweet** button

## Remove the pre-release binaries

- go to <https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/>
- remove the test binaries

## Clean the work area

Run the xPack action `trigger-workflow-deep-clean`, this
will remove the build folders on all supported platforms.

The results are available from the
[Actions](https://github.com/xpack-dev-tools/windows-build-xpack/actions/) page.
