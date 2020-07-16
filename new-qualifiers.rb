#!/bin/env ruby
# frozen_string_literal: true

# Check a Wikipedia scraper outfile against what's currently in
# Wikidata, creating wikibase-cli commands for any qualifiers to add.

require 'csv'
require 'pry'

require_relative 'lib/inputfile'

# TODO: sanity check the input
wikipedia_file = Pathname.new(ARGV.first) # output of scraper
wikidata_file = Pathname.new(ARGV.last) # `wd sparql term-members.sparql`

wikipedia = InputFile::CSV.new(wikipedia_file)
wikidata = InputFile::JSON.new(wikidata_file)

def compare(wp, wd)
  wp.keys.select { |key| key[/^P\d+/] }.each do |property|
    wp_value = wp[property]
    next if wp_value.to_s.empty?

    wd_value = wd[property] rescue binding.pry

    if wp_value.to_s == wd_value.to_s
      # warn "#{wd} matches on #{property}"
      next
    end

    if (!wd_value.to_s.empty? && (wp_value != wd_value))
      warn "*** MISMATCH for #{wp[:id]} #{property} ***: WD = #{wd_value} / WP = #{wp_value}"
      warn "\t" + [wd[:statement], property.to_s, wd_value, wp_value].join(' ')
      next
    end

    puts [wd[:statement], property.to_s, wp_value].join " "
  end
end

wikipedia.data.each do |wp|
  id = wp[:id]

  # Unless someone already has at least one relevant P39, we can't do
  # anything. Those will need created separately first.
  next unless wikidata.tally[id]

  found = wikidata.find(id)

  # If we expect one match, and it exists, compare them, regardless of
  # what's there already
  if (wikipedia.tally[id] == 1) && (wikidata.tally[id] == 1)
    compare(wp, found.first)
    next
  end

  # Otherwise look for a match with the same start date
  narrowed = found.select { |wd| wd[:P580] == wp[:P580] }
  if narrowed.count == 1
    compare(wp, narrowed.first)
    next
  end

  warn "NO SUITABLE MATCH for #{wp}"
end
