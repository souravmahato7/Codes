-- You need to pass the server name under where C.Path in ('Servernamewithfqdn')
-- You need to change the startdate and enddate

USE OperationsManagerDW
declare @startdate datetime
declare @enddate datetime
 

set @startdate = '20190816'
set @enddate = '20190917';
 

DECLARE @CPU TABLE(Path varchar(255),[DateTime] datetime, ObjectName varchar(255), CounterName varchar(255), Averagevalue int,MinValue int,MaxValue int)
DECLARE @Memory TABLE(Path varchar(255),[DateTime] datetime, ObjectName varchar(255), CounterName varchar(255), Averagevalue int,MinValue int,MaxValue int)
Declare @aggregationTypeid as int

Set @aggregationTypeid =30  --if you need for hourly, then change the value as 20

IF @AggregationTypeId = 30
 

BEGIN
 

INSERT INTO @CPU
select
vManagedEntity.Path
,Perf.vPerfDaily.DateTime
--,Perf.vPerfDaily.SampleCount
,vPerformanceRule.ObjectName
,vPerformanceRule.CounterName
,round(Perf.vPerfDaily.Averagevalue,3) As CPUAvgValue
,round(Perf.vPerfDaily.MinValue,3) as CPUMinValue
,round(Perf.vPerfDaily.MaxValue,3) as CPUMaxValue
from Perf.vPerfDaily
join vPerformanceRuleInstance on vPerformanceRuleInstance.PerformanceRuleInstanceRowid=Perf.vPerfDaily.PerformanceRuleInstanceRowid
join vPerformanceRule on vPerformanceRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
join vManagedEntity on vManagedEntity.ManagedEntityRowid=Perf.vPerfDaily.ManagedEntityRowId
join vRule on vRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
where Perf.vPerfDaily.Datetime between @startdate and @enddate
and vPerformanceRule.ObjectName='Processor Information'
and vPerformanceRule.CounterName='% processor time'
 

INSERT INTO @Memory
select
vManagedEntity.Path
,Perf.vPerfDaily.DateTime
,vPerformanceRule.ObjectName
,vPerformanceRule.CounterName
,round(Perf.vPerfDaily.Averagevalue,3) As MemoryAvgValue
,round(Perf.vPerfDaily.MinValue,3) as MemoryMinValue
,round(Perf.vPerfDaily.MaxValue,3) as MemoryMaxValue
from Perf.vPerfDaily
join vPerformanceRuleInstance on vPerformanceRuleInstance.PerformanceRuleInstanceRowid=Perf.vPerfDaily.PerformanceRuleInstanceRowid
join vPerformanceRule on vPerformanceRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
join vManagedEntity on vManagedEntity.ManagedEntityRowid=Perf.vPerfDaily.ManagedEntityRowId
join vRule on vRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
where  Perf.vPerfDaily.Datetime between @startdate and @enddate
and vPerformanceRule.ObjectName='Memory'
and vPerformanceRule.CounterName='PercentMemoryUsed'
 

SELECT
C.Path [Server Name]
,Min(C.DateTime) [Start Date]
,Max(C.DateTime) [End Date]
,cast(Min(C.MinValue) as int) [Min_CPU]
,cast(max(C.MaxValue) as int) [Max_CPU]
,cast(avg(C.Averagevalue) as int) [Avg_CPU]
,cast(Min(M.MinValue) as int) [Min_Memory]
,cast(max(M.MaxValue) as int) [Max_Memory]
,cast(avg(M.Averagevalue) as int) [Avg_Memory]
 

FROM  
@CPU C
INNER JOIN @Memory M
ON C.DateTime = M.DateTime
and C.Path = M.Path
--where C.Path in ('Servernamewithfqdn')
group by C.Path
order by C.Path
 

END

ELSE
 

BEGIN
 

INSERT INTO @CPU
select
vManagedEntity.Path
,Perf.vPerfHourly.DateTime
,vPerformanceRule.ObjectName
,vPerformanceRule.CounterName
,round(Perf.vPerfHourly.Averagevalue,3) As CPUAvgValue
,round(Perf.vPerfHourly.MinValue,3) as CPUMinValue
,round(Perf.vPerfHourly.MaxValue,3) as CPUMaxValue
from Perf.vPerfHourly
join vPerformanceRuleInstance on vPerformanceRuleInstance.PerformanceRuleInstanceRowid=Perf.vPerfHourly.PerformanceRuleInstanceRowid
join vPerformanceRule on vPerformanceRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
join vManagedEntity on vManagedEntity.ManagedEntityRowid=Perf.vPerfHourly.ManagedEntityRowId
join vRule on vRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
where Perf.vPerfHourly.Datetime between @startdate and @enddate
and vPerformanceRule.ObjectName='Processor Information'
and vPerformanceRule.CounterName='% processor time'
 

INSERT INTO @Memory
select
vManagedEntity.Path
,Perf.vPerfHourly.DateTime
,vPerformanceRule.ObjectName
,vPerformanceRule.CounterName
,round(Perf.vPerfHourly.Averagevalue,3) As MemoryAvgValue
,round(Perf.vPerfHourly.MinValue,3) as MemoryMinValue
,round(Perf.vPerfHourly.MaxValue,3) as MemoryMaxValue
from Perf.vPerfHourly
join vPerformanceRuleInstance on vPerformanceRuleInstance.PerformanceRuleInstanceRowid=Perf.vPerfHourly.PerformanceRuleInstanceRowid
join vPerformanceRule on vPerformanceRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
join vManagedEntity on vManagedEntity.ManagedEntityRowid=Perf.vPerfHourly.ManagedEntityRowId
join vRule on vRule.RuleRowId=vPerformanceRuleInstance.RuleRowId
where  Perf.vPerfHourly.Datetime between @startdate and @enddate
and vPerformanceRule.ObjectName='Memory'
and vPerformanceRule.CounterName='PercentMemoryUsed'
 

SELECT
C.Path [Server Name]
,Min(C.DateTime) [Start Date]
,Max(C.DateTime) [End Date]
,cast(Min(C.MinValue) as int) [Min_CPU]
,cast(max(C.MaxValue) as int) [Max_CPU]
,cast(avg(C.Averagevalue) as int) [Avg_CPU]
,cast(Min(M.MinValue) as int) [Min_Memory]
,cast(max(M.MaxValue) as int) [Max_Memory]
,cast(avg(M.Averagevalue) as int) [Avg_Memory]
 

FROM  @CPU C
 

INNER JOIN @Memory M
ON C.DateTime = M.DateTime
and C.Path = M.Path
--where C.Path in ('Servernamewithfqdn')
group by C.Path
order by C.Path
END
