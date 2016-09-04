# jetbrains-linux-installer
`apt-get` like alternative for linux users that allows downloading JetBrains programs such as **IntelliJ IDEA, PhpStorm, WebStorm or PyCharm**
simply from your command-line.

- **Downloads and Installs** the newest version automatically (installs into `/opt` directory)
- **Updates** to the newest version
- **Sets the permissions** accordingly
- **One command** to handle all the hassle

Doesn't create `.desktop` entries, because that's what JetBrains apps can do by themselves. Instead, it launches every app that it installed right away (after all the packages are installed), so that you can do the initial setup. (if you don't like this behaviour, use the `--no-launch` option)

```
$ jetbrains-get --help
Usage:
	jetbrains-get install [packages] [options]	Installs/upgrades packages
	jetbrains-get upgrade [packages] [options]	Installs/upgrades packages
	jetbrains-get remove [packages]			Uninstalls packages
	jetbrains-get clean				Removes all downloaded files
	jetbrains-get --help				Prints this help message and quits

Packages:
	clion, phpstorm, idea, idea-community, datagrip, pycharm, pycharm-community, rubymine

Options:
	--no-launch		Will not launch the program after installation
	--remove-downloads	Will remove all downloaded files after installation
	--force-download	Will force redownload even if file exists on disk
```

## Global installation for all users
1. `git clone https://github.com/kogli/jetbrains-linux-installer.git && cd jetbrains-linux-installer && sh install-globally.sh`
3. You might be asked to input your root password
4. `jetbrains-get` gets installed into your `/usr/local/bin` directory
5. Test if it works: `jetbrains-get --help`

## Quick use
1. Download the `jetbrains-get.sh` file
2. Call `chmod +x jetbrains-get.sh`
3. Test if it works: `./jetbrains-get.sh --help`
