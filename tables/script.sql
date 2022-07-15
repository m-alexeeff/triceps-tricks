SELECT srv.ServiceID,
	srv.Name,
	srv.EstimationCost,
	srv.LaborCost,
	Estimation,
	LaborTime,
	srv.HasConditions,
	srv.Obsolete,
	srv.Uuid

FROM Service srv

ORDER BY ServiceID

SELECT srv.Name        [Service],
	fl.Name            [Filter],
	srv.EstimationCost [SrvCost],
	sc.EstimationCostTotal,
	sc.LaborCost,
	sc.EstimationTotal,
	sc.LaborTime,
	srv.Uuid           [SrvUuid],
	sc.Uuid            [ScUuid]

FROM Service srv,
	ServiceCondition sc,
	Filter fl

WHERE sc.ServiceID = srv.ServiceID
	AND sc.FilterID = fl.FilterID

SELECT srv.ServiceID,
	srv.Name [ServiceName],
	srv.EstimationCost,
	srv.LaborCost,
	Estimation,
	LaborTime,
	srv.HasConditions,
	srv.Obsolete,
	srv.Uuid

FROM Service srv

ORDER BY ServiceID

SELECT srv.ServiceID,
	sc.ServiceConditionID,
	srv.Name               [Service],
	fl.Name                [Filter],
	srv.EstimationCost     [SrvEstimationCost],
	sc.EstimationCostTotal [SCEstimationCostTotal],
	sc.LaborCost           [SCLaborCost],
	sc.EstimationTotal     [SCEstimationTotal],
	sc.LaborTime           [SCLaborTime],
	srv.Uuid               [SrvUuid],
	sc.Uuid                [ScUuid]

FROM Service srv,
	ServiceCondition sc,
	Filter fl

WHERE sc.ServiceID = srv.ServiceID
	AND sc.FilterID = fl.FilterID

ORDER BY sc.ServiceID, ServiceConditionID