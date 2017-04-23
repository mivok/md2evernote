#!/usr/bin/env ruby
require 'kramdown'
require 'rexml/document'
require_relative 'kramdown_evernote_html'

def load_doc(filename)
  text = File.read(filename)
  Kramdown::Document.new(text)
end

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

def generate_note(doc)
  note = REXML::Document.new <<-EOF.gsub(/^\s+/, '')
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
    <en-note>
    #{doc.to_evernote_html}
    </en-note>
  EOF
  note.to_s
end

def generate_enex(notes)
  enex = REXML::Document.new <<-EOF.gsub(/^\s+/, '')
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE en-export SYSTEM "http://xml.evernote.com/pub/evernote-export3.dtd">
    <en-export />
  EOF
  enex.root.add_attributes(
    "export-date" => Time.now.utc.strftime("%Y%m%dT%H%M%SZ"),
    "application" => "md2evernote",
    "version" => "0.0.1"
  )
  notes.each do |note|
    note_elem = REXML::Element.new("note")
    title_elem = REXML::Element.new("title")
    title_elem.text = note["title"]
    content_elem = REXML::Element.new("content")
    content_elem << REXML::CData.new(note["content"])
    note_elem << title_elem
    note_elem << content_elem
    enex.root << note_elem
  end
  enex.to_s
end

notes = []
ARGV.each do |f|
  doc = load_doc(f)
  title = extract_title(doc) || File.basename(f, '.md')
  notes << {"title" => title, "content" => generate_note(doc)}
end

File.write("notes.enex", generate_enex(notes))
puts "Converted notes are in notes.enex"
