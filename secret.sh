#!/bin/sh
set -eu

program=$(basename "$0")

AGE=${AGE:-age}
SECRET_DIR=${SECRET_DIR:-~/.secret}
SECRET_PRIVATE_KEY_FILE=${SECRET_PRIVATE_KEY_FILE:-~/.age}

error()
{
	printf '%s\n' "$1" >&2
	exit 1
}

usage()
{
	u=$({
		echo "Usage: $program [entry] [field]"
		echo "       $program -e entry"
	})

	error "$u"
}

# Check for mandatory environment variables.
[ -z "${EDITOR:-}" ] && error "EDITOR is not set."
[ -z "${SECRET_PUBLIC_KEY:-}" ] && error "SECRET_PUBLIC_KEY is not set."

eflag=0
entry=''

while getopts "e:" o 2>/dev/null
do
	case "$o" in
	e)
		eflag=1
		entry="$OPTARG"
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))

# Check number of arguments.
[ $eflag -eq 0 ] && [ $# -gt 2 ] && usage
[ $eflag -gt 0 ] && [ $# -gt 0 ] && usage

# Check directory.
[ -d "$SECRET_DIR" ] || error "Directory $SECRET_DIR does not exist."

# Implementation.
if [ $eflag -eq 0 ]
then
	if [ $# -eq 0 ]
	then
		for f in $(find "$SECRET_DIR" -type f | sort)
		do
			printf '%s\n' "${f#$SECRET_DIR/}"
		done
	else
		entry_file="$SECRET_DIR/$1"

		[ -f "$entry_file" ] || error "Entry $1 does not exist."

		data=$("$AGE" -d -i "$SECRET_PRIVATE_KEY_FILE" "$entry_file")

		if [ -z "${2:-}" ]
		then
			printf '%s\n' "$data"
		else
			value=$(printf '%s\n' "$data" \
			      | grep "^$2\t" \
			      | cut -f 2)

			[ -z "$value" ] && error "Field $2 is not set."

			printf '%s\n' "$value"
		fi
	fi
else
	entry_file="$SECRET_DIR/$entry"

	if [ -f "$entry_file" ]
	then
		"$AGE" -d \
		       -i "$SECRET_PRIVATE_KEY_FILE" "$entry_file" \
		       > "$entry_file.tmp"
	else
		mkdir -p "$(dirname "$entry_file.tmp")"
		touch "$entry_file.tmp"
	fi

	chmod 600 "$entry_file.tmp"
	"$EDITOR" "$entry_file.tmp"
	"$AGE" -r "$SECRET_PUBLIC_KEY" -o "$entry_file" "$entry_file.tmp"
	rm -f "$entry_file.tmp"
fi
