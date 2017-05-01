#!/usr/bin/env ruby
# Mac only, reads markdown from the clipboard and makes a new note from it in
# evernote. Uses applescript to make the note directly in evernote, and
# kramdown to apply the same transformations as used in md2evernote.
require 'kramdown'
require 'tempfile'
require_relative 'kramdown_evernote_html'

def extract_title(doc)
  top = doc.root.children.first
  title = nil
  if top.type == :header and top.options[:level] == 1
    # The first element in the doc is a h1, make that the title
    title = top.options[:raw_text]
    # Now remove the header from the parsed text
    doc.root.children.shift
    # And remove any whitespace after the header
    while doc.root.children.first.type == :blank do
      doc.root.children.shift
    end
  end
  title
end

text = `pbpaste`
doc = Kramdown::Document.new(text, :input => :GFM, :hard_wrap => false)
title = extract_title(doc) || "No title"
converted = doc.to_evernote_html
fh = Tempfile.new(['note', '.html'])
begin
  fh.write(converted)
  fh.close()

  script = <<-EOF
  tell application "Evernote"
    create note title "#{title}" from file "#{fh.path}"
  end
  EOF

  system "osascript -e '#{script}'"
ensure
  fh.close
  fh.unlink
end
