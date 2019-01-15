module JekyllPatternbot
  PatternbotLogger = PatternbotConsoleLogger.new
  PatternbotCache = {}
  PatternbotData = {
    :css => {},
    :logos => false,
    :icons => false,
    :patterns => {},
    :pages => [],
  }

  Jekyll::Hooks.register :site, :post_read do |site|
    # File.open('/Users/thomasjbradley/Desktop/patternbot-config.json', 'w') do |f|
    #   f.write(JSON.pretty_generate(Config))
    # end

    modulifier = ModulifierParser.new(Config['patternbot']['css']['modulifier'])
    PatternbotData[:css][:modulifier] = modulifier.exists? ? modulifier.info : {}

    gridifier = GridifierParser.new(Config['patternbot']['css']['gridifier'])
    PatternbotData[:css][:gridifier] = gridifier.exists? ? gridifier.info : {}

    typografier = TypografierParser.new(Config['patternbot']['css']['typografier'])
    PatternbotData[:css][:typografier] = typografier.exists? ? typografier.info : {}

    theme = ThemeParser.new(Config['patternbot']['css']['theme'])
    PatternbotData[:css][:theme] = theme.exists? ? theme.info : {}

    logos = LogosFinder.new(Config['patternbot']['logos'])
    PatternbotData[:logos] = logos.exists? ? logos.info : {}

    icon_files = IconsFinder.new(Config['patternbot']['icons'])
    if icon_files.exists?
      icons = IconsParser.new(Config['patternbot']['icons'], icon_files.info)
      PatternbotData[:icons] = icons.info
    else
      PatternbotData[:icons] = []
    end

    pattern_files = PatternsFinder.new
    PatternbotData[:patterns] = {
      :internal => pattern_files.internal_patterns_info,
      :user => pattern_files.user_patterns_info,
    }

    pages = SamplePagesFinder.new
    PatternbotData[:pages] = pages.info

    brand_processor = BrandProcessor.new.process
    modules_processor = ModulesProcessor.new.process

    # File.open('/Users/thomasjbradley/Desktop/patternbot.json', 'w') do |f|
    #   f.write(JSON.pretty_generate(PatternbotData))
    # end
  end

end
