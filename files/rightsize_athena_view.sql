CREATE OR REPLACE VIEW rightsize_view AS
SELECT "recommendations"."currentinstance"."resourceid" "instance_id" ,
         "recommendations"."currentinstance"."instancename" "instance_name" ,
         "recommendations"."accountid" "account_id" ,
         "recommendations"."currentinstance"."resourcedetails"."ec2resourcedetails"."instancetype" "instance_type" ,
         CAST((CASE
    WHEN ("recommendations"."currentinstance"."resourceutilization"."ec2resourceutilization"."maxcpuutilizationpercentage" = '') THEN
    null
    ELSE "recommendations"."currentinstance"."resourceutilization"."ec2resourceutilization"."maxcpuutilizationpercentage" END) AS double) "max_cpu_utilization" , CAST((CASE
    WHEN ("recommendations"."currentinstance"."resourceutilization"."ec2resourceutilization"."maxmemoryutilizationpercentage" = '') THEN
    null
    ELSE "recommendations"."currentinstance"."resourceutilization"."ec2resourceutilization"."maxmemoryutilizationpercentage" END) AS double) "max_memory_utilization" , CAST((CASE
    WHEN ("recommendations"."currentinstance"."resourceutilization"."ec2resourceutilization"."maxstorageutilizationpercentage" = '') THEN
    null
    ELSE "recommendations"."currentinstance"."resourceutilization"."ec2resourceutilization"."maxstorageutilizationpercentage" END) AS double) "max_disk_utilization" , "recommendations"."rightsizingtype" "recommended_action" , (CASE
    WHEN ("recommendations"."rightsizingtype" = 'Modify') THEN
    "recommendations"."modifyrecommendationdetail"."targetinstances"[1]."resourcedetails"."ec2resourcedetails"."instancetype"
    ELSE '' END) "recommended_instance_type_1" , CAST("recommendations"."currentinstance"."monthlycost" AS double) "current_monthly_cost" , (CASE
    WHEN ("recommendations"."rightsizingtype" = 'Modify') THEN
    CAST("recommendations"."modifyrecommendationdetail"."targetinstances"[1]."estimatedmonthlycost" AS double)
    ELSE 0.0 END) "estimated_monthly_cost" , (CASE
    WHEN ("recommendations"."rightsizingtype" = 'Modify') THEN
    CAST("recommendations"."modifyrecommendationdetail"."targetinstances"[1]."estimatedmonthlysavings" AS double)
    ELSE CAST("recommendations"."currentinstance"."monthlycost" AS double) END) "estimated_monthly_savings" , "dates"."earliest_date" , "dates"."latest_date" , "dates"."frequency", "org"."name", "org"."env"
FROM ((rightsizing.rightsizing
CROSS JOIN UNNEST("rightsizingrecommendations") t (recommendations))
LEFT JOIN 
    (SELECT "recommendations"."currentinstance"."resourceid" "instance_id" ,
         "min"("date_parse"("concat"("year",
         "month",
         "day"),
         '%Y%m%d')) "earliest_date" , "max"("date_parse"("concat"("year", "month", "day"), '%Y%m%d')) "latest_date" , "count"(*) "frequency"
    FROM (rightsizing.rightsizing
    CROSS JOIN UNNEST("rightsizingrecommendations") t (recommendations))
    GROUP BY  1 ) dates
        ON ("dates"."instance_id" = "recommendations"."currentinstance"."resourceid"))
JOIN 
    (SELECT *
    FROM organisation_data) org
    ON org.id = "recommendations"."accountid"
WHERE ("date_parse"("concat"("year", "month", "day"), '%Y%m%d') >= (current_timestamp - INTERVAL '7' DAY))