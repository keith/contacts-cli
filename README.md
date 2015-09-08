# contacts-cli

A simple script for querying contacts from the command line.

## [mutt](http://www.mutt.org/) integration

Somewhere in your `muttrc`:

```
set query_command="contacts '%s'"
bind editor <Tab> complete-query
```
