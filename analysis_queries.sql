SELECT
	FLOOR(crs_dep_time / 100) AS hour_of_day,
	COUNT(flight_number) AS total_outbound_flights,
	ROUND(AVG(dep_delay)::numeric, 2) AS total_outbound_flights,
	--Calculate flights delayed by more than 15 minutes--
	ROUND((SUM(CASE WHEN dep_delay > 15 THEN 1.0  ELSE 0.0 END) / COUNT(flight_number)) * 100, 2) AS percent_delayed
FROM atl_hub_logistics
WHERE reporting_airline = 'DL' AND origin = 'ATL' AND crs_dep_time IS NOT NULL
GROUP BY FLOOR(crs_dep_time / 100)
ORDER BY hour_of_day;

SELECT 
	dest AS destination_airport,
	COUNT(flight_number) AS total_flights,
	--create reliability score--
	ROUND((1 -(SUM(CASE WHEN dep_delay > 15 OR cancelled = 1 THEN 1.0 ELSE 0.0 END) / COUNT(flight_number))) * 100, 2) AS operational_reliability_score,
	--break down root cause for delay--
	ROUND(AVG(carrier_delay)::numeric, 2) AS avg_carrier_delay,
	ROUND(AVG(weather_delay)::numeric, 2) AS avg_weather_delay,
	ROUND(AVG(late_aircraft_delay)::numeric, 2) AS avg_late_aircraft_delay
FROM atl_hub_logistics
WHERE reporting_airline = 'DL' AND origin = 'ATL'
GROUP BY dest
HAVING COUNT(flight_number) > 30
ORDER BY operational_reliability_score ASC
LIMIT 20;