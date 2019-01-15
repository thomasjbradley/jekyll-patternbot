module JekyllPatternbot

  Jekyll::Hooks.register :site, :post_read do |site|
    PatternbotLogger = Logger.new STDERR
    PatternbotCache = {}
    PatternbotData = {
      :css => {},
      :logos => false,
      :icons => false,
      :patterns => {},
      :pages => [],
    }

    PatternbotLogger.formatter = proc do |severity, datetime, progname, msg|
      "ERROR: #{datetime}: #{msg}\n"
    end

    # File.open('/Users/thomasjbradley/Desktop/patternbot-config.json', 'w') do |f|
    #   f.write(JSON.pretty_generate(Config))
    # end

    modulifier = ModulifierParser.new(Config['patternbot']['css']['modulifier'])
    PatternbotData[:css][:modulifier] = modulifier.info if modulifier.exists?

    gridifier = GridifierParser.new(Config['patternbot']['css']['gridifier'])
    PatternbotData[:css][:gridifier] = gridifier.info if gridifier.exists?

    typografier = TypografierParser.new(Config['patternbot']['css']['typografier'])
    PatternbotData[:css][:typografier] = typografier.info if typografier.exists?

    theme = ThemeParser.new(Config['patternbot']['css']['theme'])
    PatternbotData[:css][:theme] = theme.info if theme.exists?

    logos = LogosFinder.new(Config['patternbot']['logos'])
    PatternbotData[:logos] = logos.info if logos.exists?

    icon_files = IconsFinder.new(Config['patternbot']['icons'])
    if icon_files.exists?
      icons = IconsParser.new(Config['patternbot']['icons'], icon_files.info)
      PatternbotData[:icons] = icons.info
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
