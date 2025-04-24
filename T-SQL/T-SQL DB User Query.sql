-- Queries All Users in Server
SELECT name, type_desc, create_date, modify_date, is_disabled
FROM sys.server_principals
WHERE	
	is_fixed_role = 0 AND
	type IN ('S','U','G') AND
	name NOT LIKE '##%' AND
	name NOT LIKE 'NT%'
ORDER BY name;

SELECT name, type_desc
FROM sys.server_principals
WHERE	
	is_fixed_role = 0 AND
	type IN ('S','U','G') AND
	name NOT LIKE '##%' AND
	name NOT LIKE 'NT%'
ORDER BY name;