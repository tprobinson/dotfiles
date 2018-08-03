# dotfiles

My dotfiles! Not just configuration, but also useful scripts.

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [dotfiles](#dotfiles)   
- [home](#home)   
   - [.config](#config)   
      - [fish](#fish)   
         - [config.fish](#configfish)   
         - [functions](#functions)   
            - [fish_prompt.sh](#fish_promptsh)   
            - [slackme](#slackme)   
   - [.i3](#i3)   
   - [bin](#bin)   
      - [csvToProxySQLRules.pl](#csvToProxySQLRulespl)   
      - [db_dump.sh](#db_dumpsh)   
      - [display-switch.sh](#display-switchsh)   
      - [docker-debug-service](#docker-debug-service)   
      - [mysqlASCIITableToCSV.pl](#mysqlASCIITableToCSVpl)   
      - [shasum](#shasum)   
      - [updateCnameHosts.pl](#updateCnameHostspl)   
         - [Syntax](#Syntax)   
         - [Usage](#Usage)   
      - [watchrng.py](#watchrngpy)   
      - [yarn-flat-auto](#yarn-flat-auto)   
- [node](#node)   
   - [.eslintrc.js](#eslintrcjs)   
   - [yarn_eslint.sh](#yarn_eslintsh)   

<!-- /MDTOC -->

# home

Contains files to be put into home.

## .config

Various config files

### fish

Files for the [Fish shell](https://fishshell.com)

#### config.fish

Equivalent to bashrc. Just has a few path variables.

#### functions

Fish functions.

##### fish_prompt.sh

The typical fish_prompt, but with a prompt to add Terraform workspace if in a Terraform workspace.

##### slackme

A function to send myself a Slack message. Usually useful for chaining on the end of a long running process.

## .i3

Contains files for [i3wm](https://i3wm.org)

## bin

Contains useful scripts.

### csvToProxySQLRules.pl

Converts a CSV file into a [ProxySQL](http://www.proxysql.com) rules insert statement. This allows rules to be stored externally as a flat database while making reconfiguring a broken proxy easy.

### db_dump.sh

A script to make copying MySQL compatible databases from one server to another easier. Edit the variables at the top of the script to provide sort of a listing of possible databases. For example, in the script here, "PROD" and "STAGE" are possible options.

Then, edit the FROM and TO variables to use those prefixes.

Edit the BACKUP_FROM and BACKUP_TO variables to automatically backup the target databases before dumping FROM into TO.

### display-switch.sh

Probably not directly useful for anyone but me on a particular setup, but could be a good scaffold for someone else to use. Upon being triggered, will switch laptop between docked and undocked monitor configs.

Referenced in [/home/.i3/config] as Shift+Ctrl+Alt+Mod4+F1

### docker-debug-service

A script to debug a Docker Swarm service by producing a "docker run" line
from its service definition. Only the last arg is used for the service name.

Can be invoked using Docker args:
```sh
docker-debug-service -H myswarm.docker.local myservice
```

### mysqlASCIITableToCSV.pl

I hope you don't ever have to use this. It converts a text file containing an ASCII table as output by MySQL, into a CSV. Usually used for pasted terminal output. Eugh.

### shasum

A modified version of the Linux builtin shasum utility, with new flags:

| Flag | Description                   |
| ---- | ----------------------------- |
| -r   | Outputs a raw digest (binary) |
| -B   | Outputs a base64 digest       |

This has been primarily used with Terraform, since it uses base64 digests.

### updateCnameHosts.pl

This script "enhances" the `/etc/hosts` file to support CNAMES. Kind of.
Rough state, can leave extra entries if edits are made by hand.

Useful for working around temporary crappy DNS or mocking up future DNS names.
Won't remove any entries you've made in the hosts file.

Upon run, this script will create an entry with the first IP returned by that
DNS name, mapped to all aliases. If the IP changes, the line will be updated.


#### Syntax
Create a comment in the hosts file like the below:

```
# CNAME <dns name> <aliases>

# ex:
# CNAME mydns.alias internal.prod internal.stage
1.1.1.1 internal.prod internal.stage
```

#### Usage
To run as your own user, set the `/etc/hosts` file to be your group:
```sh
chgrp `whoami` /etc/hosts
```

Run on a crontab like this:
```
*/5 * * * * perl ~/bin/updateCnameHosts.pl
```

### watchrng.py

Grabbed from somewhere else, outputs total entropy bits in a loop to watch for entropy drops or gains.


### yarn-flat-auto

Grabbed from somewhere else, picks the highest version of every module automatically on a yarn --flat dependency resolution run.


# node

Files to use with Node.

## .eslintrc.js

Based on [standard](https://standardjs.com) config, enforcing a few rules I like as well as using tabs instead of spaces.

## yarn_eslint.sh

A line to run to install all the plugins necessary for the config above.
