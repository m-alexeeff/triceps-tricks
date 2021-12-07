-- Запрос, который выдаёт по клиенту количество заездов и оставленную сумму
-- Также кажет, сколько у него машин, когда заезжал последний раз.

-- Запрос можно использовать для сегментации клиентов

-- Result

WITH src AS
	(SELECT ass.AssignmentID,
		 ass.Number,
		 CASE ag.IsDisabled
			 WHEN 1 THEN N'Отключён'
			 WHEN 0 THEN N'Активен'
			 END                                               [Active],

		 ag.Name                                               [Customer],

		 (SELECT MAX(ct.Value)
		  FROM Contact ct
		  WHERE ct.AgentID = ag.AgentID
			  AND ct.Type IN (1, 2))                           [Phone],

		 ass.TotalMoney AS                                     [TotalMoney],

		 (SELECT ISNULL(SUM(api.CustomPrice * api.Quantity), 0)
		  FROM AssignmentProductItem api
		  WHERE api.AssignmentID = ass.AssignmentID)           [SumProd],

		 (UPPER(TRIM(vnd.Name)) + ' ' + UPPER(TRIM(vh
			 .Model)) + ', ' + UPPER(TRIM(vh.RegisterNumber))) [VH],
		 CAST(ass.AssignmentDateTime AS date)                  [DT],
		 post.Name                                             [Post]

	 FROM Assignment ass

	      INNER JOIN Agent ag ON ass.CustomerID = ag.AgentID
	      INNER JOIN Vehicle vh ON ass.VehicleID = vh.VehicleID
	      INNER JOIN VehicleVendor vnd ON vh.VendorID = vnd.VehicleVendorID
	      INNER JOIN Post ON ass.PostID = post.PostID

	 WHERE ass.State = 'executed'
		 AND ass.PostID NOT IN (11, 12, 14, 17)),

	ByVehicles AS
		(SELECT MAX(AssignmentID)                      [AssignmentID],
			 Active,
			 Customer,
			 Phone,

			 VH,
			 SUM(TotalMoney)                           [SumWork],
			 SUM(SumProd)                              [SumProd],
			 SUM(TotalMoney + SumProd)                 [TotalMoney],
			 MIN(DT)                                   [FirstVisit],
			 MAX(DT)                                   [LastVisit],
			 COUNT(Number)                             [VisitCount],
			 SUM(TotalMoney + SumProd) / COUNT(Number) [AvgCheque]

		 FROM src

		 GROUP BY Active, Customer, Phone, VH)

SELECT Active,
	Customer,
	Phone,

	COUNT(VH)       [VehicleCount],

	MIN(VH)         [Vehicle],

	SUM(SumWork)    [TotalWork],
	SUM(SumProd)    [TotalProd],
	SUM(TotalMoney) [TotalMoney],
	MIN(FirstVisit) [FirstVisit],
	MAX(LastVisit)  [LastVisit],
	SUM(VisitCount) [VisitCount],
	AVG(AvgCheque)  [AvgCheque]

FROM ByVehicles

GROUP BY Active, Customer, Phone

ORDER BY Customer

--SELECT * FROM Assignment WHERE CustomerID = 900 AND State = 'executed'
