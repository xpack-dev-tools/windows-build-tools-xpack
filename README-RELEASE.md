# How to make a new release (maintainer info)

## Release schedule

The xPack Windows Build Tools has no strict release schedule, but
will try to follow the GNU make release schedule, if possible.

However, make stables releases were rare, and after v4.3 git sources
were used.

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

In the `xpack-dev-tools/windows-build-tools-xpack` Git repo:

- switch to the `xpack-develop` branch
- if needed, merge the `xpack` branch

No need to add a tag here, it'll be added when the release is created.

### Check the latest upstream release

#### make

Currently the latest stable 4.3 is from 2020-01-20
(<http://mirrors.nav.ro/gnu/make/>) and fails the build.
Use the latest git commit from
<https://git.savannah.gnu.org/cgit/make.git/log/>.

#### busybox

To identify the latest commits, check the GitHub page
<https://github.com/rmyorston/busybox-w32/commits/master>.

### Increase the version

Determine the version (like `4.3.0`) and update the `scripts/VERSION`
file; the format is `4.3.0-1`. The fourth number is the xPack release number
of this version. A fifth number will be added when publishing
the package on the `npm` server.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues/>

and fix them; assign them to a milestone (like `4.3.0-1`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-RELEASE.md`
- update version in `README-BUILD.md`
- update version in `README.md`

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _- v4.3.0-1 prepared_
- commit with a message like _prepare v4.3.0-1_

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

bash ${HOME}/Work/windows-build-tools-xpack.git/scripts/helper/build.sh --develop --win
```

Work on the scripts until all platforms pass the build.

## Push the build scripts

In this Git repo:

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

From here it'll be cloned on the production machines.

## Run the CI build

The automation is provided by GitHub Actions and three self-hosted runners.

Run the `generate-workflows` to re-generate the
GitHub workflow files; commit and push if necessary.

- on the macOS machine (`xbbmi`) open ssh sessions to the Linux
machines (`xbbli`):

```sh
caffeinate ssh xbbli
```

Start the runner:

```sh
~/actions-runner/run.sh
```

Check that both the project Git and the submodule are pushed to GitHub.

To trigger the GitHub Actions build, use the xPack action:

- `trigger-workflow-build-all`

This is equivalent to:

```sh
bash ${HOME}/Work/windows-build-tools-xpack.git/scripts/helper/trigger-workflow-build.sh
```

This script requires the `GITHUB_API_DISPATCH_TOKEN` to be present
in the environment.

This command uses the `xpack-develop` branch of this repo.

The builds take about 14 minutes to complete.

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
bash ${HOME}/Work/windows-build-tools-xpack.git/scripts/helper/tests/trigger-workflow-test-prime.sh
```

These scripts require the `GITHUB_API_DISPATCH_TOKEN` variable to be present
in the environment.

These actions use the `xpack-develop` branch of this repo and the
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/)
binaries.

The tests results are available from the
[Actions](https://github.com/xpack-dev-tools/windows-build-tools-xpack/actions/) page.

### Manual tests

Install the binaries on all supported platforms and check if they are
functional, possibly by running Eclipse builds.

## Create a new GitHub pre-release draft

- in `CHANGELOG.md`, add the release date and a message like _- v4.3.0-1 released_
- commit and push the `xpack-develop` branch
- run the xPack action `trigger-workflow-publish-release`

The result is a
[draft pre-release](https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/)
tagged like **v4.3.0-1** (mind the dash in the middle!) and
named like **xPack Windows Build Tools v4.3.0-1** (mind the dash),
with all binaries attached.

- edit the draft and attach it to the `xpack-develop` branch (important!)
- save the draft (do **not** publish yet!)

## Prepare a new blog post

Run the xPack action `generate-jekyll-post`; this will leave a file
on the Desktop.

In the `xpack/web-jekyll` GitHub repo:

- select the `develop` branch
- copy the new file to `_posts/releases/windows-build-tools`
- refer to the Busybox commit and date

If any, refer to closed
[issues](https://github.com/xpack-dev-tools/windows-build-tools-xpack/issues/).

## Update the preview Web

- commit the `develop` branch of `xpack/web-jekyll` GitHub repo;
  use a message like **xPack Windows Build Tools v4.3.0-1 released**
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
  `package.json: update urls for 4.3.0-1.1 release` (without `v`)

## Publish on the npmjs.com server

- select the `xpack-develop` branch
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`, add a line like _- v4.3.0-1.1 published on npmjs.com_
- commit with a message like _CHANGELOG: publish npm v4.3.0-1.1_
- `npm pack` and check the content of the archive, which should list
  only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`;
  possibly adjust `.npmignore`
- `npm version 4.3.0-1.1`; the first 5 numbers are the same as the
  GitHub release; the sixth number is the npm specific version
- the commits and the tag should have beed pushed by the `postversion` script;
  if not, push them with `git push origin --tags`
- `npm publish --tag next` (use `--access public` when publishing for
  the first time)

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
- `npm dist-tag add @xpack-dev-tools/windows-build-tools@4.3.0-1.1 latest`
- `npm dist-tag ls @xpack-dev-tools/windows-build-tools`

In case the previous version is not functional and needs to be unpublished:

- `npm unpublish @xpack-dev-tools/windows-build-tools@4.3.0-1.X`

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
- paste the release name like **xPack Windows Build Tools v4.3.0-1 released**
- paste the link to the Web page
  [release](https://xpack.github.io/windows-build-tools/releases/)
- click the **Tweet** button

## Remove pre-release binaries

- go to <https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/>
- remove the test binaries
