

select 
	
		r.Name										as State
	,	r.Year
	,	r.B04006_049E								as SomePartIrish
    ,	r.B04007_002E								as TotalAncestrySpecified
    ,	r.B04006_049E / r.B04007_002E				as ShareOfPopulationBornInState
    
from acs1_dashboard.acs1_api_results r

where 1=1

order by
		r.Name
	,	r.Year
