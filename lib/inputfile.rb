class InputFile
  def initialize(pathname)
    @pathname = pathname
  end

  MAPPING = {
    id: %w(item),
    P4100: %w(party group),
    P768: %w(area constituency),
    P580: %w(start starttime startdate start_time start_date),
    P582: %w(end endtime enddate end_time end_date),
    P1365: %w(replaces),
    P1366: %w(replaced_by replacedby replacedBy),
    P1534: %w(cause end_cause endcause endCause),
    P1545: %w(ordinal),
  }

  def data
    # TODO: warn about unexpected keys in either file
    @data ||= raw.map do |row|
      row.transform_keys { |k| remap.fetch(k.to_s, k).to_sym }
        .transform_values do |v|
          v = v[:value] if v.class == Hash
          v.to_s.sub('T00:00:00Z','')
        end
    end
  end

  def find(id)
    data.select { |row| row[:id] == id }
  end

  def remap
    @remap ||= MAPPING.flat_map { |prop, names| names.map { |name| [name, prop.to_s] } }.to_h
  end

  def tally
    @tally ||= data.map { |r| r[:id] }.tally
  end

  attr_reader :pathname

  class CSV < InputFile
    require 'csv'

    def raw
      @data ||= ::CSV.table(pathname).map(&:to_h)
    end
  end

  class JSON < InputFile
    require 'json'

    def raw
      @data ||= ::JSON.parse(pathname.read, symbolize_names: true)
    end
  end
end
