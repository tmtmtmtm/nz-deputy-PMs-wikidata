// List of P39 data for this position. Fetch with:
//     wd sparql office-holders.sparql Q<office id> | tee wikidata.json

module.exports = office => `
  SELECT ?statement ?item ?itemLabel ?ordinal ?replaces ?replacesLabel ?replacedBy ?replacedByLabel ?start ?end WHERE {
    ?item wdt:P31 wd:Q5; p:P39 ?statement.
    ?statement ps:P39 wd:${office}.
    MINUS { ?statement wikibase:rank wikibase:DeprecatedRank. }

    OPTIONAL { ?statement pq:P580 ?start }
    OPTIONAL { ?statement pq:P582 ?end }
    OPTIONAL { ?statement pq:P1365 ?replaces }
    OPTIONAL { ?statement pq:P1366 ?replacedBy }
    OPTIONAL { ?statement pq:P1545 ?ordinal }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
  }
  ORDER BY ?start
`
