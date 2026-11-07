SECRET(1)

# NAME

secret - handle secrets using _age_(1)

# SYNOPSIS

*secret* [_entry_] [_field_] ++
*secret* -m _entry_ ++
*secret* -n _entry_

# DESCRIPTION

*secret* is a POSIX utility to handle secrets using age encryption.

If only the _entry_ argument is passed, its entire content is printed.

If the _field_ argument is passed too, its value is printed.

# OPTIONS

\-m _entry_
	Modify _entry_.

\-n _entry_
	Create _entry_ and modify it.

# ENTRIES

An _entry_, when decrypted, is a multi-line tab-separated list; each of its rows
is a _field_ of the _entry_. The first column is the name of the field, while the
second column is its value.

```
username	myusername
password	mypassword
```

# ENVIRONMENT

_EDITOR_
	The text editor. This is mandatory.

_SECRET_PUBLIC_KEY_
	The age public key. This is mandatory.

_SECRET_PRIVATE_KEY_FILE_
	The age private key file. It is set to "~/.age" by default.

_AGE_
	The age executable. It is set to "age" by default.

_SECRET_DIR_
	The directory containing the entries.  It is set to "~/.secret" by
	default.

# SEE ALSO

_age_(1)
