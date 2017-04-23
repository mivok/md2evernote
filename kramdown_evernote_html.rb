require 'kramdown/converter/html'

module Kramdown
  module Converter
    class EvernoteHtml < Html

      # Code block style that evernote generates
      CODEBLOCK_STYLE = "box-sizing: border-box; padding: 8px; font-family: Monaco, Menlo, Consolas, &quot;Courier New&quot;, monospace; font-size: 12px; color: rgb(51, 51, 51); border-top-left-radius: 4px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-bottom-left-radius: 4px; background-color: rgb(251, 250, 248); border: 1px solid rgba(0, 0, 0, 0.14902); background-position: initial initial; background-repeat: initial initial;-en-codeblock:true;"

      def convert_p(el, indent)
        # Output paragraphs as <divs>
        # The evernote mac client uses them for exported notes
        if el.options[:transparent]
          inner(el, indent)
        else
          format_as_block_html(:div, el.attr, inner(el, indent), indent)
        end
      end

      def convert_text(el, indent)
        # Evernote will run text together withoutspaces if you don't convert
        # newlines.
        escape_html(el.value.gsub(/\n/, ' '))
      end

      def convert_codeblock(el, indent)
        # Outputs codeblocks using evernote's custom style for code blocks.
        # We don't need any special processing kramdown provides in the
        # original method such as highlighting or showing spaces, so that can
        # be left out here.
        result = escape_html(el.value)
        result.chomp!
        result.gsub!("\n", "</div><div>")
        # Evernote encodes multiple spaces as alternating nbsp and normal
        # spaces, and doesn't escape them.
        result.gsub!("  ", "\u00a0 ")
        result.gsub!("  ", " \u00a0") # deal with odd numbers of spaces
        "#{' '*indent}<div style=\"#{CODEBLOCK_STYLE}\"><div>#{result}</div></div>\n"
      end

      def convert_header(el, indent)
        # Convert headers to bold text
        # Evernote uses divs and spans with style for bold text
        "#{' ' * indent}<div><span style=\"font-weight: bold;\">#{inner(el, indent)}</span></div>"
      end

      def convert_codespan(el, indent)
        # Code spans aren't really supported in evernote, so just remove them
        escape_html(el.value)
      end

      def convert_blank(el, indent)
        # This preserves blank lines in the markdown input in the final
        # evernote note. If things look too spaced out, then remove this
        # method.
        "<div><br/></div>\n"
      end
    end
  end
end
