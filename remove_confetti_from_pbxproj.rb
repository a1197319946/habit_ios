require 'xcodeproj'

project_path = 'LittleHabitTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Remove ConfettiView.swift from the main group and target
file_ref = project.main_group.find_subpath('Sources/ConfettiView.swift', false)
if file_ref
    project.targets.each do |target|
        target.source_build_phase.files_references.each do |ref|
            if ref == file_ref
                target.source_build_phase.remove_file_reference(ref)
            end
        end
    end
    file_ref.remove_from_project
end

project.save
puts "Removed ConfettiView from project"
