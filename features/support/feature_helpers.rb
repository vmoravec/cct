module FeatureHelpers
  attr_reader :scenario_tag, :feature_tag

  def filter_scenario_config_by scenario_tags
    @feature_tag, @scenario_tag = scenario_tags.map(&:name)
  end

  def with_scenario_config
    return if feature_tag.nil? || scenario_tag.nil?

    features_config = config.fetch("features", nil)
    return if features_config.nil?

    feat_tag = feature_tag.match(tag_regex).captures.first
    scen_tag = scenario_tag.match(tag_regex).captures.first

    feature_config = features_config[feat_tag]
    return if feature_config.nil?

    feature_config = feature_config[scen_tag]
    return if feature_config.nil?

    log.info("Using tags #{feature_tag} and #{scenario_tag} for filtering" +
             " the features config..")
    yield feature_config
  end

  def tag_regex
    @regex ||= /@(.+)/
  end

  def wait_for event, options
    period, period_units = options[:max].split
    sleep_period, sleep_units = options[:sleep].split if options[:sleep]
    timeout_time = convert_to_seconds(period, period_units)
    sleep_time = convert_to_seconds(sleep_period, sleep_units)
    log.info("Setting timeout to '#{event}' to max #{options[:max]}")
    timeout(timeout_time) do
      (timeout_time / sleep_time).times do
        yield
        if options[:sleep]
          log.info("Sleep for more #{options[:sleep]}")
          sleep(sleep_time)
        end
      end
    end
  rescue Timeout::Error
    message = "#{event} expired after #{period} #{period_units}"
    log.error(message)
    raise message
  end

  def convert_to_seconds period, units
    case units
    when /minute/
      period.to_i * 60
    when /second/
      period.to_i
    when nil
      0
    else
      raise "Only minutes or seconds are allowed"
    end
  end
end
