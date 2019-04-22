# How to publish the GNU MCU Eclipse Windows Build Tools binaries?

## Build

Before starting the build, perform some checks.

### Check the CHANGELOG file

Open the `CHANGELOG.txt` file from `gnu-mcu-eclipse/windows-build-tools.git` 
and check if all new entries are in.

Note: if you missed to update the `CHANGELOG.txt` before starting the build, 
edit the file and rerun the build, it should take only a few minutes to 
recreate the archives with the correct file.

### Check the version

The `VERSION` file should refer to the actual release.

### Push the project git

Push `gnu-mcu-eclipse/windows-build-tools.git` to GitHub.

Possibly push the helper project too.

### Run the build scripts

When everything is ready, follow the instructions on the 
[build](https://github.com/gnu-mcu-eclipse/windows-build-tools/blob/master/README.md) 
page.

## Test

Install the binaries on all supported platforms and check if they are 
functional.

## Create a new GitHub pre-release

- go to the [GitHub Releases](https://github.com/gnu-mcu-eclipse/windows-build-tools/releases) page
- click **Draft a new release**
- name the tag like **v2.12-20190422**
- select the `master` branch
- name the release like **GNU MCU Eclipse Windows Build Tools v2.12 20190422**
- as description
  - add a downloads badge like `[![Github Releases (by Release)](https://img.shields.io/github/downloads/gnu-mcu-eclipse/windows-build-tools/v2.12-20190422/total.svg)]()`; use empty URL for now
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- enable the pre-release button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients 
watching this project.

## Update the Change log

Open the `CHANGELOG.txt` file from `gnu-mcu-eclipse/windows-build-tools.git` 
and copy entries to the web git.

In the `gnu-mcu-eclipse.github.io-source.git` web git, add new entries to the 
[Change log](https://gnu-mcu-eclipse.github.io/windows-build-tools/change-log/) 
(`pages/windows-build-tools/change-log.md`), grouped by days.

## Prepare a new blog post

In the `gnu-mcu-eclipse.github.io-source.git` web git:

- add new entries to the 
 [Change log](https://gnu-mcu-eclipse.github.io/windows-build-tools/change-log/) 
 (`pages/windows-build-tools/change-log.md`), grouped by days.
- add a new file to `_posts/windows-build-tools/releases`
- name the file like `2019-04-22-windows-build-tools-v2-12-20190422-released.md`
- name the post like: **GNU MCU Eclipse Windows Build Tools v2.12 20190422 released**.
- as `download_url` use the tagged URL like `https://github.com/gnu-mcu-eclipse/windows-build-tools/releases/tag/v2.12-20190422/`
- update the `date:` field with the current date

If any, close [issues](https://github.com/gnu-mcu-eclipse/windows-build-tools/issues) 
on the way. Refer to them as:

- **[Issue:\[#22\]\(...\)]**.

## Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

fb4c6a3a3a93f7ac5dbd88879b782b9b1c31c4b51273dc6c8c4299c23b3c4d98
gnu-mcu-eclipse-windows-build-tools-2.12-20190422-1053-win32.zip

a8fd184310ffb5bf91660fd09f5b230675ef121deb03722c49562edf4d03318f
gnu-mcu-eclipse-windows-build-tools-2.12-20190422-1053-win64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd deploy
$ cat *.sha
```

## Update the web

- commit the `gnu-mcu-eclipse.github.io-source.git` project; use a message 
  like **Windows Build Tools v2.12-20190422 released**
- push the project
- wait for the Travis build to complete; occasionally links to not work, 
  and might need to restart the build
- remember the post URL, since it must be updated in the release page

## Create the xPack release

Follow the instructions on the 
[gnu-mcu-eclipse/arm-none-eabi-gcc-xpack](https://github.com/gnu-mcu-eclipse/windows-build-tools-xpack/blob/xpack/README.md#maintainer-info)
page.

## Create a final GitHub release

- go to the [GitHub Releases](https://github.com/gnu-mcu-eclipse/windows-build-tools/releases) page
- update the link behind the badge with the blog URL
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- copy/paste the **Easy install** section
- update the current release version
- copy/paste the **Download analytics** section
- update the current release version
- disable the pre-release button
- click the **Update Release** button

## Share on Facebook

- go to the new post and follow the Share link.
- DO NOT select **On your own Timeline**, but **On a Page you manage**
- select GNU MCU Eclipse
- posting as GNU MCU Eclipse
- click **Post to Facebook**
- check the post in the [Facebook page](https://www.facebook.com/gnu-mcu-eclipse)

## Share on Twitter

* go to the new post and follow the Tweet link
* copy the content to the clipboard
* DO NOT click the Tweet button here, it'll not use the right account
* in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
* using the `@gnu_mcu_eclipse` account, paste the content
* click the Tweet button
