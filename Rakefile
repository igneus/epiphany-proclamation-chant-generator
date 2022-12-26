def gly_preview_task(path)
  target = path.sub(/\.gly$/, '.pdf')

  file target => [path] do |t|
    sh 'gly', 'preview', t.prerequisites[0]
  end

  target
end

file 'epiphany_proclamation.gly' => ['generate.rb', 'template.gly', 'Gemfile.lock'] do |t|
  sh "ruby generate.rb > #{t.name}"
end

desc 'generate Epiphany Proclamation chants for the default year range'
task default: gly_preview_task('epiphany_proclamation.gly')

desc 'build pdf document discussing variants of the chant tune'
task var: gly_preview_task('variants.gly')
