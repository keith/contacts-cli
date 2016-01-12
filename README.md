# contacts-cli

A simple script for querying contacts from the command line.

Usage:

```sh
$ contacts query
NAME	EMAIL
query@example.com	First Last
```

## Installation

```sh
brew install keith/formulae/contacts-cli
```

OR

```sh
make install
```

### [mutt](http://www.mutt.org/) integration

Somewhere in your `muttrc`:

```
set query_command="contacts '%s'"
bind editor <Tab> complete-query
```

##### Notes

- This is a simplified replacement for the unmaintained
  [contacts](http://www.gnufoo.org/contacts/contacts.html)
- This is distributed as a compiled executable rather than a swift
  script to help with swift compatibility during new releases.
- If you have trouble running the script inside tmux see [this
  issue](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard/issues/43)
