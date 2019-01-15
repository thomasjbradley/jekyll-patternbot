module JekyllPatternbot
  class CSSFontParser

    def self.base
      {
        :primary => false,
        :secondary => false,
        :accent => [],
      }
    end

    def self.font
      {
        :name => nil,
        :name_pretty => nil,
        :css_name => nil,
        :raw => nil,
        :var => nil,
        :weights => nil,
      }
    end

    def self.font_weight
      {
        :css_name => nil,
        :weight => 'normal',
        :has_normal => false,
        :has_italic => false,
      }
    end

    def self.is_font?(dec)
      !!dec.match(/\-\-font\-/)
    end

    def self.normalize_font_weight(font_weight)
      font_weight_digits = font_weight.gsub /[^\d]/, ''
      return 'normal' if font_weight_digits == '400'
      return 'bold' if font_weight_digits == '700'
    end

    def self.rule_sets_to_weights(rulesets)
      weights = {}
      rulesets.each do |ruleset|
        font_family = ruleset.get_value('font-family').gsub(/['";]/, '')
        font_family_slug = font_family.to_slug.normalize.to_s
        weights[font_family_slug] = {} unless weights.key? font_family_slug
        font_weight = self.normalize_font_weight ruleset.get_value 'font-weight'
        weights[font_family_slug][font_weight] = self.font_weight.clone unless weights[font_family_slug].key? font_weight
        weights[font_family_slug][font_weight][:weight] = font_weight
        weights[font_family_slug][font_weight][:css_name] = ruleset.get_value('font-family').gsub(/\;/, '').strip
        weights[font_family_slug][font_weight][:has_normal] = true if ruleset.get_value('font-style').match /normal/ or ruleset.get_value('font-style').nil?
        weights[font_family_slug][font_weight][:has_italic] = true if ruleset.get_value('font-style').match /italic/
      end
      weights
    end

    def self.parse_font_file(font_url)
      if font_url
        parser = CssParser::Parser.new
        parser.load_uri!(font_url)
        font_face_rulesets = parser.find_by_selector('@font-face').map { |rules| CssParser::RuleSet.new(nil, rules) }
        return nil unless font_face_rulesets
        return self.rule_sets_to_weights font_face_rulesets
      else
        return false
      end
    end

    def self.parse_font(dec, val, available_weights)
      font_family = val.match(/[^\,\;]*/)[0].gsub(/['"]/, '')
      font_family_slug = font_family.to_slug.normalize.to_s
      font = self.font.clone
      font[:name] = font_family_slug
      font[:name_pretty] = font_family
      font[:raw] = val
      font[:var] = dec
      if available_weights and available_weights.key? font_family_slug
        font[:weights] = available_weights[font_family_slug]
        font[:css_name] = available_weights[font_family_slug].values[0][:css_name]
      end
      font
    end

    def self.parse(font_url, data)
      unless PatternbotCache.key?(font_url)
        PatternbotLogger.warn("Patternbot downloaded CSS for fonts from the remote URL: #{font_url}")
        fonts = self.base.clone
        available_weights = self.parse_font_file(font_url)
        data.each do |dec, val|
          if self.is_font? dec
            fonts[:primary] = self.parse_font(dec, val, available_weights) if dec.match(/\-\-font\-primary/)
            fonts[:secondary] = self.parse_font(dec, val, available_weights) if dec.match(/\-\-font\-secondary/)
            fonts[:accent].push self.parse_font(dec, val, available_weights) unless dec.match(/\-\-font\-(primary|secondary)/)
          end
        end
        PatternbotCache[font_url] = fonts
      else
        PatternbotLogger.info("Patternbot used a cached version of the font CSS originally located at: #{font_url}")
      end
      PatternbotCache[font_url]
    end

  end
end
