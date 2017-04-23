# md2evernote

This script converts a directory of markdown files into an evernote xml format
(enex) suitable for importing directly into evernote. It was created to
migrate my personal set of notes into evernote and is tailored to the style of
markdown files I tend to write.

While there are tools to import markdown into evernote, the results tend to
look like a copy/paste from a rendered version of the markdown, or more like a
clipped web page than a typed note. This is good for notes that you will only
look at and never change, but is not as good for notes that you will add to
over time, or notes that are imported along hand-created notes where you want
the styles to match.

This tool attempts to mimic the result you would get if you typed the notes in
by hand in the evernote mac app, and faciliate easy editing of the notes in
the mac app. Because of this, it starts by running kramdown to parse the
markdown file and generate html output, and makes a few transformations to
the text as it does so:

* The top level heading is used as the note title. If the first thing in the
  file is a h1 heading, then it is stripped from the file and used as the note
  title. Otherwise, the filename is used as the note title.
* All other headings are replaced with bold text, and no distinction is made
  between different heading levels. Evernote doesn't have a built in
  formatting option for headings, and while we could import headings as is,
  they appear in the evernote app as a custom font size, making it look
  different than hand created notes and making it difficult to edit and add to
  an existing note. To get around this, the tool just uses bold text to denote
  a heading, and only one level of heading is used.
* Code blocks are preserved, and converted to the style built in to the
  evernote mac client.  Evernote applies a custom style to code blocks
  (currently only available as a beta option on the latest mac client) and
  that style is replicated here rather than importing code blocks as is. Code
  blocks that are imported directly don't show up correctly in evernote and
  don't look any different from other text.
* Blank lines from markdown text are preserved. This tends to space out the
  text, and mimics how I hand type my notes. This can be disabled by
  commenting out the 'convert_blank' function in the code if it is not
  desired.

## Installation/Usage

The md2evernote tool makes use of kramdown, so make sure it's installed first.

Once this is done, run:

    ./md2evernote.rb ~/path/to/your/markdown/files/*.md

This will create a file `notes.enex` in the current directory, which you can
then import into evernote.

If you wish, you can use bundler instead:

    bundle
    bundle exec ./md2evernote.rb ~/path/to/your/markdown/files/*.md
