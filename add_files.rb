require 'xcodeproj'

project_path = 'LittleHabitTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath(File.join('Sources'), true)

Dir.glob("Sources/*.swift").each do |file_path|
  file_name = File.basename(file_path)
  unless group.files.map(&:path).include?(file_name)
    puts "Adding #{file_name} to Xcode project..."
    file_reference = group.new_reference(file_name)
    target.add_file_references([file_reference])
  end
end

project.save
puts "Project saved successfully."
