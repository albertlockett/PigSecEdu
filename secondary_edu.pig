-- to analyze the secondary education dataset
-- goal : to get (country, male Avg, Femal Avg)


-- Load the data
data = LOAD '/user/albert/data_sets/sec_edu.csv' 
	USING PigStorage(',')
	AS (country:chararray, subgroup:chararray, year:chararray, source:chararray,
		unit:chararray, value:chararray, value_footnotes:chararray);

-- remove the annoying quotes
data = FOREACH data GENERATE
	REPLACE(country, '"', '') 		AS country:chararray,
	REPLACE(subgroup, '"', '')		AS subgroup:chararray,
	(INT) REPLACE(year, '"','')		AS year:int,
	(INT) REPLACE(value, '"', '')	AS value:int
	;

-- Take only the data we want 
filtered_data = FILTER data BY subgroup is not null AND country is not null AND year is not null;

-- Get the male average per country
male_data = FILTER filtered_data BY (subgroup MATCHES '.*Male.*');
grouped_male = GROUP male_data BY country;
male_avg = FOREACH grouped_male GENERATE group AS country, 'M' AS gender, AVG(male_data.value) AS value;

-- Get the female average per country
female_data = FILTER filtered_data BY (subgroup MATCHES '.*Female.*');
grouped_female = GROUP female_data BY country;
female_avg = FOREACH grouped_female GENERATE group AS country, 'F' AS gender, AVG(female_data.value) AS value;

-- Join and reduce the genders
joined_data = JOIN female_avg BY country, male_avg BY country;
reduced_data = FOREACH joined_data GENERATE 
	female_avg::country AS country,
	male_avg::value AS male_value,
	female_avg::value AS female_value;
	
-- Order and output
final_dat = ORDER reduced_data BY country;
DUMP final_dat;
