GLOSS download scripts

These are a couple of shell scripts for downloading lesson media from the
United States Defense Language Institute Foreign Language Center Global
Language Online Support System (DLIFLC GLOSS). Each lesson is a .ZIP file
consisting of an audio recording (in the target language, in MP3 format)
and a text transcript (in both target language and English translation,
in PDF format). The lessons are suitable for intermediate-level learners.

There are two scripts:

	list.sh		list the languages available, and their codes
	download.sh	download all the lessons for a given language code

To use these scripts, you must have a POSIX-compatible shell. Such a
shell is standard on every modern Unix variant, such as Linux, OSX,
FreeBSD, OpenBSD, Android or Chrome OS. On Windows, Cygwin or Windows
Subsystem for Linux should work. No special shell features are required,
so bash, zsh, ksh, busybox, or even plain sh should all work.

However, /dev/fd/0 and /dev/fd/3 must be available. These are apparently
missing on AIX, HP/UX, and Cygwin, but you can supposedly get around
this by using bash, which emulates them.

In addition, some extra tools must be installed: tidy, curl, and xqilla.
If any of these are missing, first check your operating system's
package or port manager; they might be easy to install. Otherwise,
you can download the source code for the tools from these locations:

	tidy		http://html-tidy.org/
	curl		https://curl.haxx.se/
	xqilla		http://xqilla.sourceforge.net/

list.sh

This script takes no arguments. When run, it simply extracts the available
languages and their codes from the GLOSS web site, and displays them.
For example:

	sh list.sh

download.sh

This script takes one argument: the code for your desired language.
For example, for German:

	sh download.sh 7

It will download all of the lessons for that language into the current
directory. In order to avoid putting too much load on the server,
the script pauses five seconds between requests.

If the download is interrupted, you can simply try again. The script will
automatically skip over any lessons that are already fully downloaded,
and resume any lessons that have been only partially downloaded.

Some of the languages are quite large, so make sure you have enough
space. Mandarin might be the largest, at 1.9 gigabytes.

License

I hereby release this code into the public domain.

Christopher Cramer <tsuyoshi@yumegakanau.org>
