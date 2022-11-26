/*
Mexico City Airbnb Data Exploration 

Data obtained from Inside Airbnb 
*/

------------------------------------------------------Basic data cleaning----------------------------------------------------------------------
-- Check data type for every column
Select column_name, data_type
From CapstoneProject.INFORMATION_SCHEMA.COLUMNS
Where table_name = 'CDMXListings'

--Check for duplicates by counting the number of distinct listing ids and the total number of rows
Select count(distinct id),count(*)
From CapstoneProject..CDMXListings

--Find null values in the most revelant columns for our analysis
Select count(*)-count(id) as null_ids, count(*)-count(name) as null_names, count(*)-count(description) as null_description, 
count(*)-count(host_id) as null_host_ids,
count(*)-count(host_is_superhost) as null_host_is_superhost, count(*)-count(neighbourhood_cleansed) as null_neighbourhood_cleansed,
count(*)-count(latitude) as null_lat, count(*)-count(longitude) as null_lon, count(*)-count(property_type) as null_property_type,
count(*)-count(room_type) as null_room_type, count(*)-count(amenities) as null_ammenities, count(*)-count(minimum_nights) as null_minimum_nights,
count(*)-count(maximum_nights) as null_maximum_nights, count(*)-count(number_of_reviews) as null_number_of_reviews, 
count(*)-count(review_scores_rating) as null_review_scores_rating
From CapstoneProject..CDMXListings

--Clean borough names
Update dbo.CDMXListings
Set neighbourhood_cleansed = REPLACE(neighbourhood_cleansed, 'Cuauht√©moc', 'CuauhtÈmoc')

Update dbo.CDMXListings
Set neighbourhood_cleansed = REPLACE(neighbourhood_cleansed, '√Ålvaro Obreg√≥n', '¡lvaro ObregÛn')

Update dbo.CDMXListings
Set neighbourhood_cleansed = REPLACE(neighbourhood_cleansed, 'Benito Ju√°rez', 'Benito Ju·rez')

Update dbo.CDMXListings
Set neighbourhood_cleansed = REPLACE(neighbourhood_cleansed, 'Coyoac√°n', 'Coyoac·n')

Update dbo.CDMXListings
Set neighbourhood_cleansed = REPLACE(neighbourhood_cleansed, 'Tl√°huac', 'Tl·huac')

-------------------------------------------------------Data exploration-----------------------------------------------------------------------
--Property
----------------
--Most common ammenities
Select top 100 value, count(*) as number_of_mentions
From CapstoneProject..CDMXListings
Cross Apply string_split(amenities,',')
Group By value
Order By count(*) DESC

--Average price with dedicated workspace vs no dedicated workspace
Select avg(price) as avg_price_w_workspace
From CapstoneProject..CDMXListings
Where amenities like '%"Dedicated workspace"%'
Select avg(price) as avg_price_wo_workspace
From CapstoneProject..CDMXListings
Where amenities not like '%"Dedicated workspace"%'

--Number of listings by room type
Select  room_type, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group By room_type
Order By count(id) DESC

--Number of listings by property type
Select property_type, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group By property_type
Order By count(id) DESC

--Top 10 most common property types
Select property_type, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group By property_type
Order By count(id) DESC

--Most unique property types (only one of its kind)
Select property_type, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group by property_type
Having count(id) = 1
Order by count(id) DESC

--Most expensive property types
Select top 20 property_type, avg(price) as avg_price
From CapstoneProject..CDMXListings
Group by property_type
Order by avg(price) DESC

--Average price by guest limit
Select top 20 avg(price) as avg_price, accommodates
From CapstoneProject..CDMXListings
Group by accommodates
Order by avg(price) desc

--Most common guest limit
Select accommodates, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group by accommodates
Order by count(id) desc

--Most common words used to describe properties
Select top 500 value, count(*) as number_of_mentions
From CapstoneProject..CDMXListings
Cross Apply string_split(description,' ')
Group By value
Order By count(*) desc
----------------
--Host
----------------
--Amount of super host and non-super host
Select count(host_is_superhost) as number_of_superhost
From CapstoneProject..CDMXListings
Where host_is_superhost = 't'
Select count(host_is_superhost) as number_of_non_superhost
From CapstoneProject..CDMXListings
Where host_is_superhost = 'f'

--Number of listings per host
Select host_id, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group by host_id
Order by count(id) DESC

--Percentage of host with more than 1 listing
Select count(*) as number_of_listings
From CapstoneProject..CDMXListings
Group by host_id
Having count(id) = 1

--Average time as a host?
Select avg(datediff(year, host_since, '2022-09-23')) as avg_time_as_host
From CapstoneProject..CDMXListings 

--How do host describe themselves?
Select top 500 value, COUNT(*) as number_of_mentions
From CapstoneProject..CDMXListings
Cross Apply string_split(host_about,' ')
Group By value
Order By COUNT(*) DESC
----------------
--Area
----------------
--Which boroughs are more likely to described as "trendy", "hip", "chic", etc.
Select neighbourhood_cleansed, count(id) as number_of_mentions
From CapstoneProject..CDMXListings
Where (' '+neighborhood_overview+' ') like '% hip %' or neighborhood_overview like '%trendy%' or neighborhood_overview like '%chic%' or
neighborhood_overview like '%hipster%' or neighborhood_overview like '%cool%'
Group by neighbourhood_cleansed
Order by count(*) desc

--Which boroughs are more likely to be described cheap, affordable, budget-friendly, etc.
Select neighbourhood_cleansed, count(id) as number_of_mentions
From CapstoneProject..CDMXListings
Where neighborhood_overview like '%barat%' or neighborhood_overview like '%economico%' or neighborhood_overview like '%economica%'
or neighborhood_overview like'%cheap%' or neighborhood_overview like'%affordable%'
Group by neighbourhood_cleansed
Order by count(*) desc

--Number of listings by borough
Select neighbourhood_cleansed, count(id) as number_of_listings
From CapstoneProject..CDMXListings
Group by neighbourhood_cleansed

--Average price by borough
Select neighbourhood_cleansed, avg(price) as avg_price
From CapstoneProject..CDMXListings
Group by neighbourhood_cleansed
Order by avg(price) desc

--Boroughs ranked by location/value score 
Select neighbourhood_cleansed, avg(review_scores_location)
From CapstoneProject..CDMXListings
Group by neighbourhood_cleansed
Order by avg(review_scores_location) desc
Select neighbourhood_cleansed, avg(review_scores_value)
From CapstoneProject..CDMXListings
Group by neighbourhood_cleansed
Order by avg(review_scores_value) desc

--Number of listings by borough and room type
Select neighbourhood_cleansed, room_type, avg(price) as avg_price
From CapstoneProject..CDMXListings
Group by neighbourhood_cleansed, room_type
Order by avg(price) desc

--How often are popular neighborhoods listed in listing descriptions
Select neighbourhood_cleansed, count(*) as number_of_mentions_condesa
From CapstoneProject..CDMXListings
Where description like '%condesa%'
Group by neighbourhood_cleansed
Select neighbourhood_cleansed, count(*) as number_of_mentions_polanco
From CapstoneProject..CDMXListings
Where description like '%polanco%'
Group by neighbourhood_cleansed
Select neighbourhood_cleansed, count(*) as number_of_mentions_roma
From CapstoneProject..CDMXListings
Where description like '%roma%'
Group by neighbourhood_cleansed
Select neighbourhood_cleansed, count(*) as number_of_mentions_centro
From CapstoneProject..CDMXListings
Where description like '%centro historico%'
Group by neighbourhood_cleansed
Select neighbourhood_cleansed, count(*) as number_of_mentions_coyo
From CapstoneProject..CDMXListings
Where description like '%coyoacan%'
Group by neighbourhood_cleansed

