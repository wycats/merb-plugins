desc "Run the given story.  rake story[story_name]"
task :story, :story_name do |t,args|
    sh %{ruby stories/stories/#{args.story_name}.rb}
end