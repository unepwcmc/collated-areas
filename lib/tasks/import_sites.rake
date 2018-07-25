require 'csv'

namespace :import do
  desc "import CSV data into database"
  task :sites, [:csv_file] => [:environment] do |t, args|
    import_csv_file(args.csv_file)
  end

  def import_csv_file file

    csv = File.open(file)

    csv_headers = File.readlines(csv).first.split(",")

    CSV.parse(csv, :headers => true) do |row|
      site_evaluation_row = row.to_hash
      current_site_evaluation_id = site_evaluation_row["evaluation_id"]

      evaluation = Evaluation.find_or_initialize_by(id: current_site_evaluation_id)

      begin
        country_name = site_evaluation_row["country"]
        country = Country.find_or_create_by(name: country_name) do |country|
          country.iso3 = country_name
          Rails.logger.info "Country did not exist #{country_name}"
        end

        site_attributes = ["wdpa_id", "name", "designation"]
        site_hash = site_evaluation_row.select {|key, value| site_attributes.include?(key)}
        site = Site.find_or_create_by(wdpa_id: site_hash["wdpa_id"]) do |site|
          site.assign_attributes(site_hash)
        end
        evaluation.site_id = site.id

        unless evaluation.site.countries.include? country
          evaluation.site.countries << country
        end

        source_attributes = ["source_data_title", "source_resp_party", "source_year", "source_language"]
        source_hash = site_evaluation_row.select {|key, value| source_attributes.include?(key)}
                                         .each_with_object({}) {|(key, value), obj| obj[remove_source_prefix(key)] = value}

        source = Source.find_or_create_by(data_title: source_hash["data_title"]) do |source|
          source.assign_attributes(source_hash)
        end

        evaluation.source_id = source.id

        evaluation_attributes = ["metadata_id", "url", "year", "methodology"]
        evaluation_hash = site_evaluation_row.select {|key, value| evaluation_attributes.include?(key)}
        evaluation.assign_attributes(evaluation_hash)

        unless evaluation.save!
          Rails.logger.info "Cannot import! #{evaluation.id}"
        end
      rescue ActiveRecord::RecordInvalid => invalid
        Rails.logger.info "Problem with evaluation: #{site_evaluation_row["evaluation_id"]}, country: #{site_evaluation_row["country"]}"
      end

    end

    csv.close

  end

  def remove_source_prefix key
    conversion = key.to_s.dup
    conversion.slice! "source_"
    conversion
  end
end
