require 'xcodeproj'

project_path = 'LittleHabitTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)

widget_target = project.targets.find { |t| t.name == 'LittleHabitWidget' }
if widget_target
    widget_target.build_configurations.each do |config|
        config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.xiaodao.LittleHabitTracker.widget"
    end
end
project.save
puts "Bundle ID updated"
