--Paid Conversion from online mode

select r.Category,s.mobile,r.status1,r.status2,r.F_Date,r.P_Date,r.Day_Diff
from
(select h.Category,h.user_id,h.status1,l.status2,h.F_Date,l.P_Date,DATEDIFF(l.P_Date, h.F_Date) as Day_Diff

from

(SELECT a.user_id,
(case when a.price=0 then 'Free' else 'Paid' end) as Status1,
MIN(DATE(FROM_UNIXTIME(a.created + (5 * 3600) + (30 * 60)))) as F_Date,d.name as Category

FROM course_transaction_history a
left join (select course_id,main_cat,sub_cat from course_meta) c on a.course_id=c.course_id
left join (select id,name from course_stream_name_master_report)  d on d.id=c.main_cat
where
DATE(FROM_UNIXTIME(a.created + (5 * 3600) + (30 * 60)))>='2024-01-01'
and a.type!=3
and a.transaction_status=1
and a.price=0
and a.user_id not in (select distinct user_id from course_transaction_history a
where a.transaction_status=1
and DATE(FROM_UNIXTIME(a.created + (5 * 3600) + (30 * 60)))<'2024-01-01'
and a.price>0
and a.type<>3
)
GROUP BY 1,2,4
order by 1 desc,3 desc) h

left join

(SELECT d.name as Cat,a.user_id,
(case when a.price=0 then 'Free' else 'Paid' end) as Status2,
MIN(DATE(FROM_UNIXTIME(a.created + (5 * 3600) + (30 * 60)))) as P_Date

FROM course_transaction_history a
left join (select course_id,main_cat,sub_cat from course_meta) c on a.course_id=c.course_id
left join (select id,name from course_stream_name_master_report)  d on d.id=c.main_cat
where
DATE(FROM_UNIXTIME(a.created + (5 * 3600) + (30 * 60)))>='2024-01-01'
and a.price>0
and a.type!=3
and a.transaction_status=1
GROUP BY 1,2,3
order by 1 desc,3 desc) l
on h.user_id=l.user_id and h.Category=l.Cat and l.P_Date>=h.F_Date) r 
inner join (select id,mobile from users) s on r.user_id=s.id