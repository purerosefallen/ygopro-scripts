--増援
function c32807846.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32807846.target)
	e1:SetOperation(c32807846.activate)
	c:RegisterEffect(e1)
end
c32807846.cache={}
function c32807846.filter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsAbleToHand() and c32807846.CheckDiscard(c,e,tp,eg,ep,ev,re,r,rp)
end
function c32807846.CheckDiscard(c,e,tp,eg,ep,ev,re,r,rp)
	local code=c:GetOriginalCode()
	if c32807846.cache[code] then return c32807846.cache[code]==1 end
	local eset={}
	local temp=Card.RegisterEffect
	Card.RegisterEffect=function(tc,te,f)
		if (te:GetRange()&LOCATION_HAND)>0 and te:IsHasType(0x7e0) then
			table.insert(eset,te:Clone())
		end
		return temp(tc,te,f)
	end
	local tempc=c32807846.IgnoreActionCheck(Duel.CreateToken,c:GetControler(),code)
	Card.RegisterEffect=temp
	local found=false
	for _,te in ipairs(eset) do
		local cost=te:GetCost()
		if cost then
			local mt=getmetatable(tempc)
			local temp_=Effect.GetHandler
			Effect.GetHandler=function(e)
				if e==te then return tempc end
				return temp_(e)
			end
			mt.IsDiscardable=function(tc,...)
				if tempc==tc then found=true end
				return Card.IsDiscardable(tc,...)
			end
			pcall(function()
				cost(te,tp,eg,ep,ev,re,r,rp,0)
			end)
			mt.IsDiscardable=nil
			Effect.GetHandler=temp_
		end
	end
	c32807846.cache[code]=(found and 1 or 0)
	return found
end
function c32807846.IgnoreActionCheck(f,...)
	Duel.DisableActionCheck(true)
	local cr=coroutine.create(f)
	local ret={}
	while coroutine.status(cr)~="dead" do
		local sret={coroutine.resume(cr,...)}
		for i=2,#sret do
			table.insert(ret,sret[i])
		end
	end
	Duel.DisableActionCheck(false)
	return table.unpack(ret)
end
function c32807846.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c32807846.filter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c32807846.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c32807846.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
