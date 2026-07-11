require 'xcodeproj'

project_path = 'LittleHabitTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)

app_target = project.targets.find { |t| t.name == 'LittleHabitTracker' }
if app_target.nil?
    puts "Error: Main app target not found"
    exit 1
end

widget_name = 'LittleHabitWidget'
widget_group = project.main_group.find_subpath(File.join('Sources', widget_name), true)
widget_group.set_source_tree('<group>')
widget_group.set_path(widget_name)

# Create Widget Target
widget_target = project.new_target(:app_extension, widget_name, :ios, '17.0')
widget_target.product_name = widget_name

# Add framework dependencies
widget_target.add_system_framework('WidgetKit')
widget_target.add_system_framework('SwiftUI')

# Add files to widget group
widget_source = widget_group.new_file('LittleHabitWidget.swift')
widget_target.source_build_phase.add_file_reference(widget_source)

# We also need to compile Models.swift and DesignSystem.swift and Constants.swift in the widget
# so they can be shared
models_ref = project.main_group.find_subpath('Sources/Models.swift', false)
if models_ref
    widget_target.source_build_phase.add_file_reference(models_ref)
end

ds_ref = project.main_group.find_subpath('Sources/DesignSystem.swift', false)
if ds_ref
    widget_target.source_build_phase.add_file_reference(ds_ref)
end

constants_ref = project.main_group.find_subpath('Sources/Constants.swift', false)
if constants_ref
    widget_target.source_build_phase.add_file_reference(constants_ref)
end

# Build settings for Widget
widget_target.build_configurations.each do |config|
    config.build_settings['INFOPLIST_FILE'] = "Sources/#{widget_name}/Info.plist"
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.littlehabit.tracker.widget"
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "Sources/#{widget_name}/#{widget_name}.entitlements"
end

# App Group Entitlements
app_entitlements_path = "Sources/LittleHabitTracker.entitlements"
unless File.exist?(app_entitlements_path)
    File.write(app_entitlements_path, <<~PLIST)
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>com.apple.security.application-groups</key>
        <array>
            <string>group.com.littlehabit.tracker</string>
        </array>
    </dict>
    </plist>
    PLIST
    
    app_ent_ref = project.main_group.find_subpath('Sources').new_file('LittleHabitTracker.entitlements')
    app_target.build_configurations.each do |config|
        config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "Sources/LittleHabitTracker.entitlements"
    end
end

widget_entitlements_path = "Sources/#{widget_name}/#{widget_name}.entitlements"
File.write(widget_entitlements_path, <<~PLIST)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.littlehabit.tracker</string>
    </array>
</dict>
</plist>
PLIST
widget_ent_ref = widget_group.new_file("#{widget_name}.entitlements")


# Write Info.plist
info_plist_path = "Sources/#{widget_name}/Info.plist"
File.write(info_plist_path, <<~PLIST)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
PLIST
widget_info_ref = widget_group.new_file('Info.plist')

# Create a stub widget source file
File.write("Sources/#{widget_name}/LittleHabitWidget.swift", <<~SWIFT)
import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habits: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), habits: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), habits: [])
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
}

struct LittleHabitWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Habit Tracker Widget")
        }
    }
}

@main
struct LittleHabitWidget: Widget {
    let kind: String = "LittleHabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LittleHabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
SWIFT

# Embed widget in app target
embed_phase = app_target.new_copy_files_build_phase("Embed App Extensions")
embed_phase.dst_subfolder_spec = "13" # Plugins
embed_phase.add_file_reference(widget_target.product_reference)

# Add target dependencies
app_target.add_dependency(widget_target)

project.save
puts "Successfully added Widget Extension target!"

