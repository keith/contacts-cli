# contacts-cli

A simple tool for querying and exporting the macOS contacts database from the command line.

## Usage:

Here's an overview of the commands:

```sh
OVERVIEW: Query and export contacts from the command line

USAGE: contacts-command [--version] <search-string> [--output-type <output-type>] [--search-field <search-field>]

ARGUMENTS:
  <search-string>         The query input. Use '-' to read from stdin.

OPTIONS:
  --version               Print out the version of the application.
  --output-type <output-type>
                          (values: csv, json; default: csv)
  --search-field <search-field>
                          (values: fullName, firstName, lastName, email, all; default: all)
  -h, --help              Show help information.
```

And some specific examples:

```sh
$ contacts query
fullName,firstName,lastName,email
First Last,First,Last,query@example.com,First Last

$ echo '{"rowid": 1, "Name": "First Last"}' | jq -r '.Name' | xargs -I{} contacts {} --search-field fullName --output-type json | jq -r '.[0].email' | tr -d '\n'
fullName,firstName,lastName,email
First Last,First,Last,query@example.com,First Last
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
