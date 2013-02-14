module ApplicationHelper
  def color_version(version)
    label_class = valid_version?(version) ? 'label-success' : 'label-important'
    content_tag :span, version, class: "label #{ label_class }"
  end

  def valid_version?(program_version)
    return if program_version.to_i == 0
    return unless supported_branch = @versions.find do |version|
      significant_version(version) == significant_version(program_version)
    end
    Gem::Version.new(program_version) >= Gem::Version.new(supported_branch)
  end

  def significant_version(program_version)
    major, minor, build = Gem::Version.new(program_version).segments
    Gem::Version.new "#{ major }.#{ minor}"
  end
end
