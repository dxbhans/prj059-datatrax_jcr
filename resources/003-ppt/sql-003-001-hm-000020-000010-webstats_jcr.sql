SELECT * FROM ttmaps.pageview as ttp;

SELECT ttp.pagename,COUNT(*) FROM ttmaps.pageview as ttp
WHERE YEAR(viewdate) = 2024
GROUP BY ttp.pagename;

SELECT ttp.pagename, ttp.pagetype, COUNT(*) FROM ttmaps.pageview as ttp
WHERE YEAR(viewdate) = 2024
GROUP BY ttp.pagename, ttp.pagetype;

SELECT ttp.pagetype, COUNT(*) FROM ttmaps.pageview as ttp
WHERE YEAR(viewdate) = 2024
GROUP BY ttp.pagetype;

SELECT * FROM ttmaps.pageview as ttp
WHERE YEAR(viewdate) = 2024
AND ttp.pagetype <> '';

# "Aintree", "Carlisle", "Cheltenham", "Epsom Downs", "Exeter", "Haydock Park", "Huntingdon", "Kempton Park", "Market Rasen", "Newmarket", "Nottingham", "Sandown Park", "Warwick", "Wincanton"

SELECT * FROM ttmaps.course ttc;
