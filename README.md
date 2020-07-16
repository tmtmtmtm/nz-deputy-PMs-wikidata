Note: This repo is largely a snapshop record of bring Wikidata
information in line with Wikipedia, rather than code specifically
deisgned to be reused.

The code and queries etc here are unlikely to be updated as my process
evolves. Later repos will likely have progressively different approaches
and more elaborate tooling, as my habit is to try to improve at least
one part of the process each time around.

---------

Step 1: Check the Position Item
===============================

The Wikidata item for the [Deputy Prime Minister of New Zealand](https://www.wikidata.org/wiki/Q5261068)
looks mostly good, except it didn't have a Country: New Zealand claim.

Step 2: Tracking page
=====================

Initial PositionHolderHistory list set up at https://www.wikidata.org/w/index.php?title=Talk:Q5261068&oldid=1232704576

Current status: looks fairly close to complete, though with 11 warnings.

Step 3: Set up the metadata
===========================

Item ID, and source URL set in [add_P39.js script](add_P39.js).

So the first step now is always to edit that file.

Step 4: Scrape
==============
Comparison/source = [Deputy Prime Minister of New Zealand](https://en.wikipedia.org/wiki/Deputy_Prime_Minister_of_New_Zealand)

    wb ee --dry add_P39.js  | jq -r '.claims.P39.references.P4656' |
      xargs bundle exec ruby scraper.rb | tee wikipedia.csv

Scraped cleanly on first pass.

Step 5: Get local copy of Wikidata information
==============================================

Again, we can now get the argument to this from the JSON, so call it as:

    wb ee --dry add_P39.js | jq -r '.claims.P39.value' |
      xargs wd sparql office-holders.js | tee wikidata.json


Step 6: Create missing P39s
===========================

    bundle exec ruby new-P39s.rb wikipedia.csv wikidata.json |
      wd ee --batch --summary "Add missing P39s, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

5 new additions -> https://tools.wmflabs.org/editgroups/b/wikibase-cli/1e4d15d2a652a/

Step 7: Add missing qualifiers
==============================

    bundle exec ruby new-qualifiers.rb wikipedia.csv wikidata.json |
      wd aq --batch --summary "Add missing qualifiers, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

-> https://tools.wmflabs.org/editgroups/b/wikibase-cli/1737373f21f21/

Also a couple of mismatches, including one significant one with the start date for Holyoake being 5 years different. His own enwiki page supports the 1954 date, rather than the 1949 one, so I'll update that with

    wd uq 'Q637012$76508B86-88E2-4F10-BB96-F2ED122E67A5' P580 1949-12-13 1954-11-13

Similarly, Jim Anderton's enwiki page supports the 10th December rather
than 5th December, so I'll accept the suggested update and run

    wd uq 'Q1036723$3CACC642-4711-4879-9A31-EE6C2907BFE8' P580 1999-12-05 1999-12-10

Step 8: Refresh the Tracking Page
=================================

Those updates give us https://www.wikidata.org/w/index.php?title=Talk:Q6866068&oldid=1232665270

Most the problems here seem to be because Jack Marshall rightly has two
P39s, but both of them are set to the same dates, when they should be
different. Both of those are pre-existing, rather than a problem with
the scripts here. I could delete one and then re-run the scripts once
the QueryService catches up, but probably easier and quicker to just
manually update one of them.

Actually, they both needed edited, but hopefully 
[this](https://www.wikidata.org/w/index.php?title=Q284733&type=revision&diff=1232714967&oldid=1192422164) 
should do the trick

Final version: https://www.wikidata.org/w/index.php?title=Talk:Q5261068&oldid=1232716538




