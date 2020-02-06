-- Daily aggregation of worker data

-- Settings For 1440min data 

update pogodb.stats_worker set TpSt = 1 where TpSt > 3600 and RPL = 60;

select @Datetime := concat(date(now() - interval 1440 minute),' ', SEC_TO_TIME((TIME_TO_SEC(time(now() - interval 1440 minute)) DIV 86400) * 86400));

INSERT INTO pogodb.stats_worker (Datetime,RPL, TRPL, Worker, Tmon, IVmon, Mon, Quest, Raid, Tloc,LocOk,LocNok,LocFR,Tp,TpOk,TpNok,TpFR,TpSt,Wk,WkOk,WkNok,WkFR,WkSt,Shiny,Res,Reb,ResTot,RebTot)
select
@Datetime,
'1440',
sum(TRPL),
Worker,
sum(Tmon),
sum(IVmon),
sum(Mon),
sum(Quest),
sum(Raid),
sum(Tloc),
sum(LocOk),
sum(LocNok),
sum(LocNok)/(sum(Tloc)+0.000001)*100,
sum(Tp),
sum(TpOk),
sum(TpNok),
sum(TpNok)/(sum(Tp)+0.000001)*100,
sum(tpSt),
sum(Wk),
sum(WkOk),
sum(WkNok),
sum(WkNok)/(sum(Wk)+0.000001)*100,
sum(WkSt),
sum(Shiny),
sum(Res),
sum(Reb),
max(ResTot),
max(RebTot)

from pogodb.stats_worker
where Datetime like concat(lpad(@Datetime,10),'%') and RPL = 60
group by Worker
;
