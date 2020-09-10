with temp as (
	select
		dataset_id,
		md.title,
		nodes."name" as node,
		flat->>'measurementType' as type,
		flat->>'measurementTypeID' as typeID,
		flat->>'measurementValue' as value,
		flat->>'measurementValueID' as valueID,
		flat->>'measurementUnit' as unit,
		flat->>'measurementUnitID' as unitID,
		case when flat->>'measurementTypeID' is null then 1 else 0 end as typeID_missing,
		case when not(flat->>'measurementValue' ~ '^[-+]?[0-9\.]+$') and flat->>'measurementValueID' is null then 1 else 0 end as valueID_missing,
		case when flat->>'measurementUnit' is not null and flat->>'measurementUnitID' is null then 1 else 0 end as unitID_missing,
		case when not(flat->>'measurementValue' ~ '^[-+]?[0-9\.]+$') then 1 else 0 end as valueID_required
	from mof
	left join metadata.datasets md on md.id = mof.dataset_id 
	left join datasets on datasets.id = mof.dataset_id 
	left join nodes on nodes.id = any(datasets.node_ids)
)
select
	dataset_id,
	title,
	node,
	count(*),
	count(type) as type,
	count(typeID) as typeID,
	count(value) as value,
	count(valueID) as valueID,
	count(unit) as unit,
	count(unitID) as unitID,
	sum(typeID_missing) as typeID_missing,
	sum(valueID_missing) as valueID_missing,
	sum(unitID_missing) as unitID_missing,
	sum(valueID_required) as valueID_required
from temp
group by dataset_id, title, node
order by node, title
