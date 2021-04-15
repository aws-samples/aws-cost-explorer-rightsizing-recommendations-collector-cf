SELECT * FROM "rightsizing"."rightsizing_view" 
left join
(SELECT * FROM "rightsizing"."organisation_data" )
on rightsizing_view.account_id = organisation_data.id