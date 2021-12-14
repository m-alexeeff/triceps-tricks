SELECT srv.ServiceID,
	srv.Name,
	srv.EstimationCost,
	NULL     [WantedCost],
	NULL     [NewCost],
	srv.LaborCost,
	srv.Estimation,
	srv.LaborTime,
	srv.HasConditions,
	srv.Obsolete,
	srv.Uuid [SrvUuid]

FROM Service srv

ORDER BY srv.Name

SELECT srv.Name        [Service],
	fl.Name            [Filter],
	srv.EstimationCost [ServiceCost],
	sc.EstimationCostTotal,
    NULL [WantedCost],
    NULL [NewCost],
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

ORDER BY srv.Name, fl.Name