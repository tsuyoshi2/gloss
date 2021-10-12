#! /bin/sh
# Download all the lessons for a given language from the Defense
# Language Institute's GLOSS (gloss.dliflc.edu).
# Christopher Cramer <tsuyoshi@yumegakanau.org>
case $# in
	1) language="$1";;
	*)
		printf 'usage: %s <language code>\n' "$0" >&2
		exit 1
esac
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
require_command xqilla
require_command unzip
pause () {
	printf '%s' "$2" >&2
	sleep "$1" || fail "interrupted."
	printf '%s' "$2" | awk '{ gsub(/./, "\b \b"); printf "%s", $0 }' >&2
}
search () {
	pause 5 "Pausing before performing a search..."
	curl \
		--fail --silent --show-error \
		--data-urlencode action=search \
		--data-urlencode page="$1" \
		--data-urlencode searchString= \
		--data-urlencode languageIds="$language" \
		--data-urlencode levelIds= \
		--data-urlencode modalityIds= \
		--data-urlencode competenceIds= \
		--data-urlencode topicIds= \
		--data-urlencode subTopicIds= \
		--data-urlencode video=0 \
		--data-urlencode statusIds= \
		--data-urlencode mine= \
		--data-urlencode sortBy=alphabetical \
		https://gloss.dliflc.edu/LessonJSON.aspx \
	|| fail "search failed"
}
strip_nonascii () {
	# xqilla seems to have some trouble parsing UTF-8 JSON
	# we don't actually need those characters anyway
	iconv -c -f utf8 -t ascii
}
parse () {
	xqilla /dev/fd/3 3<<-'EOF' || fail "parse failed"
		let $json := xqilla:parse-json(unparsed-text("/dev/fd/0"))
		return (
			string($json//pair[@name = "pageCount"]),
			for $link in $json//pair[@name = "lessons"]
				/item/pair
					[@name = "mediaLink"]
					[@type = "string"]
			return string($link)
		)
	EOF
}
download () {
	base=$(basename "$1")
	if test -e "$base"; then
		if unzip -t "$base" > /dev/null 2>&1; then
			printf 'Found valid zipfile %s; skipping.\n' "$base"
			return 0
		else
			printf 'Found invalid zipfile %s; continuing.\n' \
				"$base"
			continue="--continue-at -"
		fi
	else
		continue=
	fi
	pause 5 "Pausing before downloading..."
	printf 'Downloading %s... ' "$1" >&2
	curl \
		$continue \
		--silent --show-error --remote-name \
		https://gloss.dliflc.edu/"$1" \
	|| fail "download failed."
	printf 'done.\n' >&2
}
page=1
while search $page | strip_nonascii | parse | {
	IFS= read -r pages
	printf "%s\n" "$pages" | grep -Eq '^[0-9]+$' || fail "parse failed"
	while IFS= read -r link; do
		download "$link"
	done
	test "$page" -ne "$pages"
}; do page=$((page + 1)); done
true
