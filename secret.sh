#!/bin/sh
set -eu

program=$(basename "$0")

AGE=${AGE:-age}
SECRET_DIR=${SECRET_DIR:-~/.secret}
SECRET_PRIVATE_KEY_FILE=${SECRET_PRIVATE_KEY_FILE:-~/.age}

error()
{
	printf '%s\n' "$1"
	exit 1
}

usage()
{
	u=$({
		echo "Usage: $program [entry] [field]"
		echo "       $program -m entry"
		echo "       $program -n entry"
	})

	error "$u"
}

# Check for mandatory environment variables.
[ -z "${EDITOR:-}" ] && error "EDITOR is not set."
[ -z "${SECRET_PUBLIC_KEY:-}" ] && error "SECRET_PUBLIC_KEY is not set."

m=0
n=0
arg=''

while getopts "m:n:" o 2>/dev/null
do
	case "$o" in
	m)
		m=1
		arg="$OPTARG"
		;;
	n)
		n=1
		arg="$OPTARG"
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))

# Check number of arguments.
[ $((m + n)) -eq 0 ] && [ $# -gt 2 ] && usage
[ $((m + n)) -gt 0 ] && [ $# -gt 0 ] && usage

# Unflagged implementations.
[ $((m + n)) -eq 0 ] && [ $# -eq 0 ] && [ -d "$SECRET_DIR" ] && ls "$SECRET_DIR"
if [ $((m + n)) -eq 0 ] && [ $# -gt 0 ]
then
	entry_file="$SECRET_DIR/$1"

	[ -f "$entry_file" ] || error "Entry $1 does not exist."

	data=$("$AGE" -d -i "$SECRET_PRIVATE_KEY_FILE" "$entry_file")

	if [ -z "${2:-}" ]
	then
		printf '%s\n' "$data"
	else
		line=$(printf '%s' "$data" | grep "^$2 ")
		value=$(echo "$line" \
		      | sed 's/^[^[:space:]]*[[:space:]][[:space:]]*//')

		[ -z "$value" ] && error "Field $2 is not set."

		echo "$value"
	fi
fi

# M flag imlpementation
if [ $m -eq 1 ]
then
	entry_file="$SECRET_DIR/$arg"

	[ -f "$entry_file" ] || error "Entry $arg does not exist."

	"$AGE" -d \
	       -i "$SECRET_PRIVATE_KEY_FILE" "$entry_file" > "$entry_file.tmp"
	chmod 600 "$entry_file.tmp"
	"$EDITOR" "$entry_file.tmp"
	"$AGE" -r "$SECRET_PUBLIC_KEY" -o "$entry_file" "$entry_file.tmp"
	shred -un 5 "$entry_file.tmp"
	chmod 600 "$entry_file"
fi

# N flag imlpementation
if [ $n -eq 1 ]
then
	entry_file="$SECRET_DIR/$arg"

	[ -f "$entry_file" ] && error "Entry $arg already exists."

	mkdir -p "$SECRET_DIR"
	touch "$entry_file.tmp"
	chmod 600 "$entry_file.tmp"
	"$EDITOR" "$entry_file.tmp"
	"$AGE" -r "$SECRET_PUBLIC_KEY" -o "$entry_file" "$entry_file.tmp"
	shred -un 5 "$entry_file.tmp"
	chmod 600 "$entry_file"
fi
