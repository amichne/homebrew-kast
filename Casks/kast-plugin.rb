# frozen_string_literal: true

artifact_version = "0.7.16"
artifact_root = ENV.fetch("HOMEBREW_KAST_ARTIFACT_ROOT", "https://github.com/amichne").chomp("/")
plugin_release_root = ENV.fetch(
  "HOMEBREW_KAST_PLUGIN_RELEASE_ROOT",
  "#{artifact_root}/kast/releases/download",
).chomp("/")

jetbrains_config_root = lambda do
  Pathname.new(
    ENV.fetch(
      "KAST_JETBRAINS_CONFIG_ROOT",
      "#{Dir.home}/Library/Application Support/JetBrains",
    ),
  )
end

intellij_plugin_dirs = lambda do
  root = jetbrains_config_root.call
  next [] unless root.directory?

  dirs = Dir.glob((root/"{IntelliJIdea,IdeaIC}[0-9]*.[0-9]*/plugins").to_s).filter_map do |path|
    product = File.basename(File.dirname(path))
    match = product.match(/\A(?:IntelliJIdea|IdeaIC)(\d+)\.(\d+)\z/)
    next unless match

    [match[1].to_i, match[2].to_i, Pathname.new(path)]
  end

  dirs.sort_by { |major, minor, _path| [-major, -minor] }.map(&:last)
end

cask "kast-plugin" do
  version artifact_version
  sha256 "94cdc2e76a3cd91f9ea0488636260f4091005ebaba09df18b3b9d9e40c975e33"

  url "#{plugin_release_root}/v#{version}/kast-intellij-v#{version}.zip"
  name "Kast IntelliJ Plugin"
  desc "IntelliJ IDEA plugin bundle for Kast Kotlin analysis"
  homepage "https://github.com/amichne/kast"

  livecheck do
    url "https://github.com/amichne/kast-rs/releases"
    strategy :github_releases
  end

  stage_only true

  postflight do
    plugin_root = staged_path/"backend-intellij"
    plugins_dir = intellij_plugin_dirs.call.first

    if plugins_dir.nil?
      opoo <<~EOS
        No IntelliJ IDEA config directory was found under #{jetbrains_config_root.call}.
        Launch IntelliJ IDEA once, then run `brew reinstall kast-plugin`.
      EOS
      next
    end

    link_path = plugins_dir/"kast"
    FileUtils.mkdir_p plugins_dir

    if link_path.symlink?
      current = link_path.readlink.to_s
      if current == plugin_root.to_s
        ohai "Kast plugin already linked in #{plugins_dir}"
        next
      end
      unless current.include?("/kast-plugin/")
        opoo "Not replacing existing link: #{link_path} -> #{current}"
        next
      end
      link_path.delete
    elsif link_path.exist?
      opoo "Not replacing existing path: #{link_path}"
      next
    end

    FileUtils.ln_s plugin_root, link_path
    ohai "Linked Kast plugin into #{plugins_dir}"
  end

  uninstall_postflight do
    plugin_root = staged_path/"backend-intellij"

    intellij_plugin_dirs.call.each do |plugins_dir|
      link_path = plugins_dir/"kast"
      next unless link_path.symlink?

      current = link_path.readlink.to_s
      next if current != plugin_root.to_s && current.exclude?("/Caskroom/kast-plugin/")

      link_path.delete
    end
  end

  caveats <<~EOS
    kast-plugin links the Homebrew-managed plugin into the newest IntelliJ IDEA
    config directory found on this Mac. Restart IntelliJ IDEA to load it.

    Set KAST_JETBRAINS_CONFIG_ROOT before install if your JetBrains config
    directory is not under ~/Library/Application Support/JetBrains.
  EOS
end
