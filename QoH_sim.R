# pull ticket
# pull card if first ticket
rm(list=ls(all=TRUE))
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# functions
`%!in%`=Negate(`%in%`)
special_case=function(unturned_deck,pot) {
  card=sample(unturned_deck,1)
  if(card=='QH') winning=pot*0.9
  else if(grepl('Q',card)) winning=6000
  else winning=3000
  list(card=card,winning=winning)
}
draw=function(all_tickets,my_tickets,unturned_deck,pot) {
  # winnings for a single draw (not considering multiple weeks)
  prob_me=my_tickets/all_tickets
  tickets=sample(c(
    rep(FALSE,all_tickets-my_tickets),
    rep(TRUE,my_tickets)),
    5,
    replace=FALSE)
  # calculate all possible returns at once
  case_winnings=c(special_case(unturned_deck,pot)$winning,2000,1500,1000,500)
  # winnings
  return(tickets*case_winnings)
}
newdeck=function() {
  # full deck
  deck=expand.grid(
    card=c(2:10,c('J','Q','K','A')),
    suit=c('C','S','D','H')
  )
  c(rep('joker',2),paste0(deck$card,deck$suit))
}
unturned=function(week) {
  # the unturned deck at a specific week cannot contain any jokers or QHs
  # this function subsets the full deck generates a possible deck at week `week`
  deck=newdeck()
  turned_deck=deck[deck %!in% c('QH','joker')]
  turned_deck=sample(turned_deck,week,replace=FALSE)
  deck[deck %!in% turned_deck] # the unturned deck
}
simulation=function(week,my_tickets,all_tickets,niter=1000) {
  winnings=c()
  for(iter in 1:niter) {
    unturned_deck=unturned(week)
    outcomes=draw(all_tickets,my_tickets,unturned_deck,pot)
    winnings[iter]=sum(outcomes)-my_tickets # -cost to play
  }
  mean(winnings)
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# parameters
my_tickets=10
all_tickets=my_tickets*1000 # 1/1000 chance of winning ticket on single draw
pot=all_tickets # same same
niter=1e3 # number of simulation iterations
week=20 # week into the draws. # week non-QHs/jokers will be removed from deck
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# simulation varying proportion of initial tickets and total pot size
my_tix_p=seq(0.01,0.1,0.01)
numtix=c(1000,5000,10000,25000)
res=matrix(nr=length(my_tix_p),nc=length(numtix))
for(i in 1:length(my_tix_p)) {
  for(j in 1:length(numtix)) {
    res[i,j]=simulation(week,round(numtix[j]*my_tix_p[i]),numtix[j]) 
  }
}
png('QoH_simres.png',width=4,height=4,units='in',res=400)
cols=RColorBrewer::brewer.pal(ncol(res),'Set1')
matplot(my_tix_p,res,type='b',lty=1,pch=19,cex=1/3,lwd=2,
        xlim=range(my_tix_p)*c(1,1.1),
        col=cols,
        main=paste('Week',week),
        xlab='% tickets that are yours',
        ylab='winnings')
abline(h=0)
text(x=max(my_tix_p)*1.075,y=tail(res,1),
     label=round(tail(res,1)),
     cex=2/3,
     col=cols)
legend('bottomleft',
       title='Pot',
       legend=paste0(numtix/1e3,'K'),
       lty=1,
       lwd=rep(1.5,ncol(res)),
       cex=3/5,
       col=cols)
dev.off()
