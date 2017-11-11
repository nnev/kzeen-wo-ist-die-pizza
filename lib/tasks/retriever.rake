namespace :retriever do
  desc "Downloads fresh copies of store config JSON files."
  task refresh: :environment do
    JsonCache.destroy_all

    br = ::Remote::Branch.main
    list = br.categories.each do |cat|
      cat.products.each do |prod|
        # prod.name triggers another call
        puts "#{br.name} / #{cat.name} / #{prod.name}"
      end
    end
  end
end
