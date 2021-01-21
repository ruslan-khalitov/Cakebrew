platform :osx, '10.14'

target 'Cakebrew' do
  use_frameworks!
  pod 'AppCenter'
  pod 'DCOAboutWindow', '~> 0.3.1'
  pod 'PXSourceList', '~> 2.0.7', :inhibit_warnings => true
  pod 'Sparkle', '~> 1.22.0'

  target 'CakebrewTests' do
    inherit! :search_paths
    use_frameworks!
    # Pods for testing
    pod 'AppCenter'
  end

end

plugin 'cocoapods-keys', {
  :project => "Cakebrew",
  :keys => [
    "AppCenterSecret",
    "AppCenterLogURL",
    "AppCenterDistributeApi",
    "AppCenterDistributeInstallUrl",
    "AppCenterProd"
  ]
}

# post_install do |installer|
#   installer.aggregate_targets.each do |aggregate_target|
#     aggregate_target.xcconfigs.each do |config_name, config_file|
#       # puts config_name
#       # config_file.attributes.each do |key, value|
#       #   puts "Key #{key}"
#       #   puts "Value #{value}"
#       # end
#       config_file.attributes['AC_SECRET'] = ENV['AppCenterSecret']
#       xcconfig_path = aggregate_target.xcconfig_path(config_name)
#       config_file.save_as(xcconfig_path)
#     end
#   end
# end
