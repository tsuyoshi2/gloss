#! /bin/sh
# List language codes for use with GLOSS download script
# Christopher Cramer <tsuyoshi@yumegakanau.org>
fail () {
	printf '%s: %s\n' "$0" "$1" >&2
	exit 1
}
require_directory () {
	test -d "$1" || fail "$1 not found"
}
require_command () {
	command -v "$1" > /dev/null || fail "$1 not found"
}
require_directory /dev/fd
require_command curl
require_command tidy
require_command xqilla
curl --silent --show-error https://gloss.dliflc.edu/ \
| tidy \
	--output-xml yes \
	-quiet \
	--show-warnings no \
	--numeric-entities yes \
	--output-bom no \
| xqilla -i /dev/stdin /dev/fd/3 3<<-'EOF' || fail "parse failed"
	let $selector := //div[@id = "LanguageSelectorDivContainer"]
	for $language in $selector/div[@class = "selectorDiv"]
	return concat($language/input/@value, "&#x9;", $language/label)
EOF
