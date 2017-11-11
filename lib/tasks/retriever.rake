namespace :retriever do
  desc "Ensures all store config JSON files are cached."
  task retrieve: :environment do
    br = ::Remote::Branch.main
    list = br.categories.each do |cat|
      cat.products.each do |prod|
        # prod.name triggers another call
        puts "#{br.name} / #{cat.name} / #{prod.name}"
      end
    end
  end

  desc "Downloads fresh copies of store config JSON files."
  task refresh: :environment do
    JsonCache.destroy_all
    Rake::Task['retriever:retrieve'].execute
  end
end
