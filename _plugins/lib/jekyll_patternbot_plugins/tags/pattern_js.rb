module JekyllPatternbot

  module PatternJS

    def self.js
      js = {}
      js_files.each do |file|
        js[FileHelpers.strip file] = File.read(file)
      end
      js
    end

    def self.js_files
      FileHelpers.list_files_with_ext Config['patternbot']['source'], 'js'
    end

  end

  class PatternJSTag < Liquid::Tag
    def render(context)
      PatternJS.js.map { |k, v| v } .join("\n")
    end
  end

end

Liquid::Template.register_tag('pattern_js', JekyllPatternbot::PatternJSTag)
