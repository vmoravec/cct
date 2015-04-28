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
end
