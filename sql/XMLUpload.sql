-- Query for upload data into XML format

USE Triceps2020

DECLARE @SentVersion int
--SET @BC = '06130'
SET @SentVersion = 47310735

-- Greedy Algorithm

/*UPDATE Assignment SET ReplModified = 0 WHERE CustomerID IN (Select AgentID From Agent WHERE Version >= @SentVersion AND AgentID != 2 AND AgentType  = 4)
UPDATE Vehicle SET ReplModified = 0 WHERE AgentID IN (Select AgentID From Agent WHERE Version >= @SentVersion AND AgentID != 2 AND AgentType = 4)
UPDATE AssignmentProductItem SET ReplModified = 0 WHERE AssignmentID IN (Select AssignmentID From Assignment WHERE CustomerID IN (Select AgentID From Agent WHERE Version >= @SentVersion AND AgentID != 2 AND AgentType  = 4))
UPDATE AssignmentServiceUsage SET ReplModified = 0 WHERE AssignmentID IN (Select AssignmentID From Assignment WHERE CustomerID IN (Select AgentID From Agent WHERE Version >= @SentVersion AND AgentID != 2 AND AgentType = 4))*/

-- Сама выгрузка

SELECT ag.AgentID,
	ag.Name,
	ag.CreatedDate,
	ag.BirthDate,

	(SELECT MAX(Value)
	 FROM Contact ct
	 WHERE ct.AgentID = ag.AgentID
		 AND ct.[Primary] = 1
		 AND ct.Type IN (1, 2)) [Phone],

	(SELECT MAX(Value)
	 FROM Contact ct
	 WHERE ct.AgentID = ag.AgentID
		 AND ct.Type = 3)       [Email],

	AG.Barcode,
	AG.Turnover,
	ag.Balance,
	ag.Discount,
	ag.Version

FROM Agent ag

WHERE ag.AgentType IN (4, 6, 20)
	AND ag.AgentID != 2
	AND ag.[Version] >= @SentVersion

FOR XML RAW ('Agent'), ROOT ('Agents'), ELEMENTS XSINIL

SELECT MAX(version)
FROM Agent

/* Информация по автомобилю */

SELECT vh.VehicleID,
	ag.AgentID,
	vnd.Name [Vendor],
	vh.Model,
	vh.RegisterNumber,

	vh.VIN,
	vh.FrameNumber,
	vh.EngineNumber,
	vh.HaulDistance,
	vh.IssueDateString,
	vh.Version

FROM Agent ag,
	Vehicle vh,
	VehicleVendor vnd

WHERE vh.AgentID = ag.AgentID
	AND vh.VendorID = vnd.VehicleVendorID
	AND vh.Deleted IS NULL
	AND ag.AgentID != 2
	--AND AG.Barcode IN (@BC. '0001'. '00007')
	AND vh.[Version] >= @SentVersion

FOR XML RAW ('Vehicle'), ROOT ('Vehicles'), ELEMENTS XSINIL

SELECT MAX(version)
FROM Vehicle

/*Наряды */

SELECT ass.AssignmentID,
	ag.AgentID,
	ass.VehicleId,
	ass.Number,

	ass.DateTimeIn                                                              [DTI],

	ass.DateTimeOut                                                             [DTO],

	ass.CustomerReason,
	ass.CustomerRecomendation,

	ass.HaulDistance,

	mc.Name                                                                     [Examiner],

	ass.TotalMoney                                                              [SumWork],

	(SELECT ISNULL(SUM(api.CustomPrice * api.Quantity), 0)
	 FROM AssignmentProductItem api
	 WHERE api.AssignmentID = ass.AssignmentID)                                 [SumProd],

		ISNULL(ass.TotalMoney, 0) + (SELECT ISNULL(SUM(api.CustomPrice * api.Quantity), 0)
		                             FROM AssignmentProductItem api
		                             WHERE api.AssignmentID = ass.AssignmentID) [SumTotal],

	ass.Version

FROM Assignment ass,
	Agent ag,
	Mechanic mc

WHERE ass.CustomerID = ag.AgentID
	AND ass.ExaminerID = mc.MechanicID
	AND ass.State = 'executed'
	AND ass.CustomerID != 2
	AND ass.[Version] >= @SentVersion

FOR XML RAW ('Assignment'), ROOT ('Asses'), ELEMENTS XSINIL

SELECT MAX(version)
FROM Assignment

-- Товары в нарядах

SELECT api.AssignmentProductItemID,
	ass.AssignmentID,
	ag.AgentID,
	ass.VehicleID,
	vnd.Name                       [Vendor],
	prd.Name                       [ProductName],

	prd.OEM,
	api.InitialPrice,
	api.CustomPrice,
	api.Quantity,
	api.CustomPrice * api.Quantity [SumProd],
	api.Version

FROM Assignment ass,
	Agent ag,
	AssignmentProductItem api,
	Product prd

	LEFT JOIN Vendor vnd ON prd.VendorID = vnd.VendorID

WHERE ass.CustomerID = ag.AgentID
	AND api.AssignmentID = ass.AssignmentID
	AND api.ProductID = prd.ProductID
	AND ass.State = 'executed'
	AND ass.CustomerID != 2
	AND api.[Version] >= @SentVersion

FOR XML RAW ('Product'), ROOT ('AssProducts'), ELEMENTS XSINIL

SELECT MAX(version)
FROM AssignmentProductItem

/* Работы в нарядах*/

SELECT asu.AssignmentServiceUsageID,
	ass.AssignmentID,
	ag.AgentID,
	ass.VehicleID,
	srv.Name                                                        [Service],
	mc.Name                                                         [Mechanic],
	asu.Discount,
	CAST(asu.Quantity AS Decimal(24, 5))     AS                     [Quantity],
	CAST(asu.InitialPrice AS Decimal(24, 5)) AS                     [InitialPrice],
	CAST(asu.CustomEstimationCost AS Decimal(24, 5))                [Price],
	CAST(asu.Quantity * asu.CustomEstimationCost AS Decimal(24, 5)) [Sum],

	asu.Version

FROM Assignment ass,
	Agent ag,
	AssignmentServiceUsage asu,
	[Service] srv,
	Mechanic mc

WHERE ass.CustomerID = ag.AgentID
	AND asu.AssignmentID = ass.AssignmentID
	AND asu.ServiceID = srv.ServiceID
	AND COALESCE(asu.MechanicID, ass.MechanicID) = mc.MechanicID
	AND ass.State = 'executed'
	AND ass.CustomerID != 2
	AND asu.Deleted IS NULL
	AND asu.[Version] >= @SentVersion

FOR XML RAW ('Work'), ROOT ('AssWorks'), ELEMENTS XSINIL

SELECT MAX(version)
FROM AssignmentServiceUsage

UPDATE Agent
	SET Balance_SID = 10
WHERE Balance_SID != 10
	AND AgentType = 4 -- Балансы клиентов

UPDATE Agent
	SET Balance_SID = 13
WHERE Balance_SID != 13
	AND AgentType = 6 -- Балансы сотрудников