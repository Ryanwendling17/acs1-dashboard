
select 
	
		r.Name										as State
	,	r.Year
	,	r.B01003_001E								as TotalPopulationEstimate
    ,	r.B05002_003E								as BornInStatePopulationEstimate
    ,	r.B05002_003E / r.B01003_001E				as ShareOfPopulationBornInState
    
from acs1_dashboard.acs1_api_results r

where 1=1

order by
		r.Name
	,	r.Year
