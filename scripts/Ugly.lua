-- ================================================================
-- NPC CONTROLLER v9
-- Row 1: Freeze NPCs (exile cách cũ)
-- Row 2: Proximity Prompts (clone PP cho mobile)
-- Row 3: Auto Fire Event (loop NPCInteraction mỗi 1s)
-- Row 4: Về vị trí ban đầu
-- Row 5: Return Back
-- Floating Button (ScreenGui riêng): fire NPCInteraction 1 lần, có drag
-- ================================================================

local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local TweenService= game:GetService("TweenService")
local RepStorage  = game:GetService("ReplicatedStorage")
local player      = Players.LocalPlayer

-- ================================================================
-- UTILS
-- ================================================================
local function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=p; return c end
local function pad(p,t,b,l,r) local x=Instance.new("UIPadding"); x.PaddingTop=UDim.new(0,t or 0); x.PaddingBottom=UDim.new(0,b or 0); x.PaddingLeft=UDim.new(0,l or 0); x.PaddingRight=UDim.new(0,r or 0); x.Parent=p end
local function tw(o,props,t,s,d) TweenService:Create(o,TweenInfo.new(t or 0.18,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),props):Play() end
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local function grad(p,c0,c1,rot) local g=Instance.new("UIGradient"); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c0),ColorSequenceKeypoint.new(1,c1)}); g.Rotation=rot or 90; g.Parent=p; return g end
local function regrad(f,c0,c1,rot) local o=f:FindFirstChildOfClass("UIGradient"); if o then o:Destroy() end; return grad(f,c0,c1,rot) end

-- ================================================================
-- PALETTE
-- ================================================================
local C={
    pA=rgb(24,26,40),pB=rgb(11,12,18),
    hA=rgb(30,33,52),hB=rgb(13,14,22),
    rA=rgb(33,37,56),rB=rgb(18,20,30),
    rHA=rgb(42,47,70),rHB=rgb(22,25,38),
    rDA=rgb(16,17,25),rDB=rgb(9,10,15),
    sA=rgb(14,15,22),sB=rgb(7,8,13),
    mA=rgb(95,240,175),mB=rgb(38,155,95),
    bA=rgb(100,190,255),bB=rgb(38,108,205),bD=rgb(10,30,65),
    oA=rgb(255,195,80),oB=rgb(170,90,15),oD=rgb(44,24,4),
    vA=rgb(190,140,255),vB=rgb(95,48,200),
    rdA=rgb(255,100,70),rdB=rgb(160,30,15),
    tOffA=rgb(48,52,76),tOffB=rgb(20,22,34),
    tOnA=rgb(65,220,140),tOnB=rgb(28,130,70),
    kA=rgb(242,246,255),kB=rgb(172,178,200),
    kOnA=rgb(252,255,252),kOnB=rgb(195,235,210),
    t0=rgb(218,224,240),t1=rgb(112,122,148),t2=rgb(52,60,80),
    tM=rgb(100,238,172),tB=rgb(108,188,255),tO=rgb(255,188,82),tV=rgb(188,145,255),tR=rgb(255,140,120),
}

-- ================================================================
-- COMPONENT FACTORIES
-- ================================================================
local function makeToggle(parent)
    local track=Instance.new("Frame"); track.Parent=parent; track.Size=UDim2.new(0,46,0,26); track.Position=UDim2.new(1,-56,0.5,-13); track.BackgroundColor3=C.tOffA; track.BorderSizePixel=0; track.ZIndex=6; corner(track,13); grad(track,C.tOffA,C.tOffB)
    local rim=Instance.new("UIStroke"); rim.Color=rgb(7,8,12); rim.Thickness=1; rim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; rim.Parent=track
    local knob=Instance.new("Frame"); knob.Parent=track; knob.Size=UDim2.new(0,20,0,20); knob.Position=UDim2.new(0,3,0.5,-10); knob.BackgroundColor3=C.kA; knob.BorderSizePixel=0; knob.ZIndex=8; corner(knob,10); grad(knob,C.kA,C.kB)
    return track,knob,rim
end
local function makeRow(parent,order)
    local f=Instance.new("Frame"); f.Parent=parent; f.Size=UDim2.new(1,0,0,50); f.BackgroundColor3=C.rA; f.BorderSizePixel=0; f.LayoutOrder=order; f.ZIndex=4; corner(f,11); grad(f,C.rA,C.rB); return f
end
local function accentBar(row,c0,c1)
    local a=Instance.new("Frame"); a.Parent=row; a.Size=UDim2.new(0,3,0,24); a.Position=UDim2.new(0,10,0.5,-12); a.BackgroundColor3=c0; a.BorderSizePixel=0; a.ZIndex=7; corner(a,2); grad(a,c0,c1); return a
end
local function mainLbl(row,text,col)
    local l=Instance.new("TextLabel"); l.Parent=row; l.BackgroundTransparency=1; l.Size=UDim2.new(1,-84,0,22); l.Position=UDim2.new(0,22,0,6); l.Text=text; l.TextSize=13; l.Font=Enum.Font.GothamBold; l.TextColor3=col; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=7; return l
end
local function subLbl(row,text,col)
    local l=Instance.new("TextLabel"); l.Parent=row; l.BackgroundTransparency=1; l.Size=UDim2.new(1,-20,0,13); l.Position=UDim2.new(0,22,1,-19); l.Text=text; l.TextSize=10; l.Font=Enum.Font.Gotham; l.TextColor3=col; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=7; return l
end
local function clickBtn(row,ca,cb,hca,hcb)
    local b=Instance.new("TextButton"); b.Parent=row; b.Size=UDim2.new(1,0,1,0); b.BackgroundTransparency=1; b.Text=""; b.ZIndex=9
    b.MouseEnter:Connect(function() regrad(row,hca,hcb) end); b.MouseLeave:Connect(function() regrad(row,ca,cb) end)
    return b
end

-- ================================================================
-- SHARED: fire NPCInteraction event
-- ================================================================
local function fireNPCEvent()
    pcall(function()
        RepStorage:WaitForChild("Events"):WaitForChild("NPCInteraction"):FireServer(
            "PlayerCaught", {Base="Base6", Force=0}
        )
    end)
end

-- ================================================================
-- MAIN GUI
-- ================================================================
local Gui=Instance.new("ScreenGui"); Gui.Name="NpcCtrlV9"; Gui.Parent=game.CoreGui; Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local Shadow=Instance.new("ImageLabel"); Shadow.Parent=Gui; Shadow.BackgroundTransparency=1; Shadow.Image="rbxassetid://6014261993"; Shadow.ImageColor3=rgb(0,0,0); Shadow.ImageTransparency=0.44; Shadow.ScaleType=Enum.ScaleType.Slice; Shadow.SliceCenter=Rect.new(49,49,450,450); Shadow.ZIndex=1

local PW=224; local PH=400; local PM=42

local Panel=Instance.new("Frame"); Panel.Name="Panel"; Panel.Parent=Gui; Panel.Size=UDim2.new(0,PW,0,PH); Panel.Position=UDim2.new(0,28,0.5,-(PH/2)); Panel.BackgroundColor3=C.pA; Panel.BorderSizePixel=0; Panel.Active=true; Panel.ZIndex=2; Panel.ClipsDescendants=false; corner(Panel,16); grad(Panel,C.pA,C.pB)
local panelRim=Instance.new("UIStroke"); panelRim.Color=rgb(40,44,66); panelRim.Thickness=1; panelRim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; panelRim.Parent=Panel

local DD=Instance.new("UIDragDetector"); DD.ResponseStyle=Enum.UIDragDetectorResponseStyle.Offset; DD.DragStyle=Enum.UIDragDetectorDragStyle.TranslatePlane; DD.Parent=Panel
RunService.Heartbeat:Connect(function() local p=Panel.Position; Shadow.Position=UDim2.new(p.X.Scale,p.X.Offset-18,p.Y.Scale,p.Y.Offset-16) end)

-- HEADER
local Header=Instance.new("Frame"); Header.Parent=Panel; Header.Size=UDim2.new(1,0,0,42); Header.Position=UDim2.new(0,0,0,0); Header.BackgroundColor3=C.hA; Header.BorderSizePixel=0; Header.ZIndex=5; corner(Header,16); grad(Header,C.hA,C.hB)
local HFill=Instance.new("Frame"); HFill.Parent=Panel; HFill.Size=UDim2.new(1,0,0,16); HFill.Position=UDim2.new(0,0,0,26); HFill.BackgroundColor3=C.hB; HFill.BorderSizePixel=0; HFill.ZIndex=6; grad(HFill,C.hA,C.hB)
local TitleLbl=Instance.new("TextLabel"); TitleLbl.Parent=Header; TitleLbl.Size=UDim2.new(1,-72,1,0); TitleLbl.Position=UDim2.new(0,16,0,0); TitleLbl.BackgroundTransparency=1; TitleLbl.Text="NPC Control"; TitleLbl.TextSize=13; TitleLbl.Font=Enum.Font.GothamBold; TitleLbl.TextColor3=C.t0; TitleLbl.TextXAlignment=Enum.TextXAlignment.Left; TitleLbl.ZIndex=8
local DragHint=Instance.new("TextLabel"); DragHint.Parent=Header; DragHint.Size=UDim2.new(0,36,1,0); DragHint.Position=UDim2.new(0.5,-18,0,0); DragHint.BackgroundTransparency=1; DragHint.Text="· · ·"; DragHint.TextSize=11; DragHint.Font=Enum.Font.Gotham; DragHint.TextColor3=C.t2; DragHint.TextXAlignment=Enum.TextXAlignment.Center; DragHint.ZIndex=8
local MinBtn=Instance.new("TextButton"); MinBtn.Parent=Header; MinBtn.Size=UDim2.new(0,26,0,26); MinBtn.Position=UDim2.new(1,-36,0.5,-13); MinBtn.BackgroundColor3=rgb(30,34,52); MinBtn.BorderSizePixel=0; MinBtn.Font=Enum.Font.GothamBold; MinBtn.Text="−"; MinBtn.TextSize=16; MinBtn.TextColor3=C.t1; MinBtn.ZIndex=9; corner(MinBtn,7); grad(MinBtn,rgb(44,49,74),rgb(19,21,33))
local mRim=Instance.new("UIStroke"); mRim.Color=rgb(52,58,86); mRim.Thickness=1; mRim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; mRim.Parent=MinBtn
MinBtn.MouseEnter:Connect(function() regrad(MinBtn,rgb(56,63,96),rgb(24,27,44)) end); MinBtn.MouseLeave:Connect(function() regrad(MinBtn,rgb(44,49,74),rgb(19,21,33)) end)
local Divider=Instance.new("Frame"); Divider.Parent=Panel; Divider.Size=UDim2.new(1,-24,0,1); Divider.Position=UDim2.new(0,12,0,42); Divider.BackgroundColor3=rgb(36,40,60); Divider.BorderSizePixel=0; Divider.ZIndex=7

-- CONTENT CLIP
local CC=Instance.new("Frame"); CC.Name="CC"; CC.Parent=Panel; CC.Size=UDim2.new(1,0,1,-44); CC.Position=UDim2.new(0,0,0,44); CC.BackgroundTransparency=1; CC.ZIndex=3; CC.ClipsDescendants=true
local Content=Instance.new("Frame"); Content.Parent=CC; Content.Size=UDim2.new(1,0,1,0); Content.BackgroundTransparency=1; Content.ZIndex=3
local CL=Instance.new("UIListLayout"); CL.Parent=Content; CL.SortOrder=Enum.SortOrder.LayoutOrder; CL.Padding=UDim.new(0,5); CL.FillDirection=Enum.FillDirection.Vertical; CL.HorizontalAlignment=Enum.HorizontalAlignment.Center
pad(Content,8,8,11,11)

-- ================================================================
-- ROWS
-- ================================================================
-- Row 1: Freeze
local FR=makeRow(Content,1); local FAcc=accentBar(FR,C.t2,C.t2); local FLbl=mainLbl(FR,"Freeze NPCs",C.t0); local FSub=subLbl(FR,"0 / ? bị khóa",C.t2); local FBtn=clickBtn(FR,C.rA,C.rB,C.rHA,C.rHB); local FTrack,FKnob,FRim=makeToggle(FR)

-- Row 2: Proximity Prompts
local PPR=makeRow(Content,2); local PPAcc=accentBar(PPR,C.t2,C.t2); local PPLbl=mainLbl(PPR,"Proximity Prompts",C.t0); local PPSub=subLbl(PPR,"Clone prompt cho mobile",C.t2); local PPBtn=clickBtn(PPR,C.rA,C.rB,C.rHA,C.rHB); local PPTrack,PPKnob,PPRim=makeToggle(PPR)

-- Row 3: Auto Fire
local AFR=makeRow(Content,3); local AFAcc=accentBar(AFR,C.rdA,C.rdB); local AFLbl=mainLbl(AFR,"Auto Fire Event",C.tR); local AFSub=subLbl(AFR,"NPCInteraction mỗi 1 giây",C.t2); local AFBtn=clickBtn(AFR,C.rA,C.rB,C.rHA,C.rHB); local AFTrack,AFKnob,AFRim=makeToggle(AFR)

-- Row 4: Teleport
local TR=makeRow(Content,4); local TAcc=accentBar(TR,C.bA,C.bB); local TLbl=mainLbl(TR,"Về vị trí ban đầu",C.tB); local TSub=subLbl(TR,"Lưu vị trí → teleport",C.t2); local TBtn=clickBtn(TR,C.rA,C.rB,C.rHA,C.rHB)

-- Row 5: Return Back
local RR=makeRow(Content,5); regrad(RR,C.rDA,C.rDB); local RAcc=accentBar(RR,C.t2,C.t2); local RLbl=mainLbl(RR,"Return Back",C.t2); local RSub=subLbl(RR,"Nhấn 'Về ban đầu' trước",C.t2)
local RBtn=Instance.new("TextButton"); RBtn.Parent=RR; RBtn.Size=UDim2.new(1,0,1,0); RBtn.BackgroundTransparency=1; RBtn.Text=""; RBtn.ZIndex=9

-- Status bar
local SR=Instance.new("Frame"); SR.Parent=Content; SR.Size=UDim2.new(1,0,0,26); SR.BackgroundColor3=C.sA; SR.BorderSizePixel=0; SR.LayoutOrder=6; SR.ZIndex=4; corner(SR,8); grad(SR,C.sA,C.sB)
local SDot=Instance.new("Frame"); SDot.Parent=SR; SDot.Size=UDim2.new(0,6,0,6); SDot.Position=UDim2.new(0,10,0.5,-3); SDot.BackgroundColor3=C.t2; SDot.BorderSizePixel=0; SDot.ZIndex=6; corner(SDot,3)
local SLbl=Instance.new("TextLabel"); SLbl.Parent=SR; SLbl.Size=UDim2.new(1,-26,1,0); SLbl.Position=UDim2.new(0,23,0,0); SLbl.BackgroundTransparency=1; SLbl.Text="Chờ lệnh"; SLbl.TextSize=10; SLbl.Font=Enum.Font.Gotham; SLbl.TextColor3=C.t2; SLbl.TextXAlignment=Enum.TextXAlignment.Left; SLbl.ZIndex=6

Shadow.Size=UDim2.new(0,PW+32,0,PH+32)

-- MINIMIZE
local isMin=false
MinBtn.MouseButton1Click:Connect(function()
    isMin=not isMin; local h=isMin and PM or PH
    tw(Panel,{Size=UDim2.new(0,PW,0,h)},0.24,Enum.EasingStyle.Quart)
    tw(Shadow,{Size=UDim2.new(0,PW+32,0,h+32)},0.24,Enum.EasingStyle.Quart)
    Divider.Visible=not isMin; MinBtn.Text=isMin and "+" or "−"
    if isMin then regrad(Panel,C.hA,C.hB); panelRim.Color=rgb(28,32,50)
    else regrad(Panel,C.pA,C.pB); panelRim.Color=rgb(40,44,66) end
end)

-- ================================================================
-- FREEZE LOGIC
-- ================================================================
local isFrozen=false; local npcFolder=workspace:FindFirstChild("LocalNPCs"); local NPC_PREFIX="LocalGuard_"; local frozenData={}; local EXILE=Vector3.new(99999,99999,99999)

local function getNPCs()
    local list={}; if not npcFolder then return list end
    for _,c in pairs(npcFolder:GetChildren()) do if c.Name:sub(1,#NPC_PREFIX)==NPC_PREFIX then table.insert(list,c) end end
    return list
end

local function deepFreeze(npc,status)
    local key=tostring(npc); local data=frozenData[key] or {}; frozenData[key]=data
    local directHRP=npc:FindFirstChild("HumanoidRootPart")
    local hrp=directHRP or (npc:IsA("Model") and npc.PrimaryPart) or npc:FindFirstChildWhichIsA("BasePart",true)
    local isSimple=directHRP~=nil and npc:FindFirstChildOfClass("Humanoid")~=nil
    if status and hrp then data.origCF=hrp.CFrame end
    for _,obj in pairs(npc:GetDescendants()) do
        if obj:IsA("BasePart") then
            if status then data[obj]={an=obj.Anchored,ct=obj.CanTouch,cc=obj.CanCollide}; obj.Anchored=true; obj.CanTouch=false; obj.CanCollide=false; obj.Velocity=Vector3.zero; obj.RotVelocity=Vector3.zero; obj.AssemblyLinearVelocity=Vector3.zero; obj.AssemblyAngularVelocity=Vector3.zero; pcall(function() obj:SetNetworkOwner(nil) end)
            else local s=data[obj]; if s then obj.Anchored=s.an; obj.CanTouch=s.ct; obj.CanCollide=s.cc end end
        elseif obj:IsA("Humanoid") then
            if status then data[obj]={ws=obj.WalkSpeed,jp=obj.JumpPower,ps=obj.PlatformStand}; obj.WalkSpeed=0; obj.JumpPower=0; obj.PlatformStand=true
            else local s=data[obj]; if s then obj.WalkSpeed=s.ws; obj.JumpPower=s.jp; obj.PlatformStand=s.ps end end
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            if status then data[obj]={d=obj.Disabled}; obj.Disabled=true
            else local s=data[obj]; if s then obj.Disabled=s.d end end
        elseif obj:IsA("Animator") or obj:IsA("AnimationController") then
            if status then pcall(function() for _,t in pairs(obj:GetPlayingAnimationTracks()) do t:Stop(0) end end) end
        elseif obj:IsA("Motor6D") then
            if status then data[obj]={mv=obj.MaxVelocity}; obj.MaxVelocity=0
            else local s=data[obj]; if s then obj.MaxVelocity=s.mv end end
        elseif obj:IsA("BodyMover") or obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("LinearVelocity") or obj:IsA("AngularVelocity") or obj:IsA("VectorForce") or obj:IsA("Torque") then
            if status then data[obj]={en=obj.Enabled}; obj.Enabled=false
            else local s=data[obj]; if s then obj.Enabled=s.en end end
        end
    end
    if isSimple then
        if status then directHRP.CFrame=CFrame.new(EXILE)
        else local cf=data.origCF; if cf then directHRP.Anchored=false; directHRP.CFrame=cf end end
    else
        if not status and hrp then hrp.Anchored=false end
    end
end

local function setFreezeUI(on,count)
    local total=#getNPCs()
    if on then
        regrad(FTrack,C.tOnA,C.tOnB); FRim.Color=rgb(20,105,58); tw(FKnob,{Position=UDim2.new(1,-23,0.5,-10)}); regrad(FKnob,C.kOnA,C.kOnB); regrad(FAcc,C.mA,C.mB); FLbl.TextColor3=C.tM; FSub.Text=count.." / "..total.." bị khóa"; FSub.TextColor3=rgb(55,175,105); regrad(FR,rgb(16,34,24),rgb(8,18,13)); tw(SDot,{BackgroundColor3=C.mB}); SLbl.Text="Freeze ON  ·  "..count.." NPC"; SLbl.TextColor3=C.tM; if not isMin then regrad(Panel,rgb(13,20,16),rgb(7,12,9)) end
    else
        regrad(FTrack,C.tOffA,C.tOffB); FRim.Color=rgb(7,8,12); tw(FKnob,{Position=UDim2.new(0,3,0.5,-10)}); regrad(FKnob,C.kA,C.kB); regrad(FAcc,C.t2,C.t2); FLbl.TextColor3=C.t0; FSub.Text="0 / "..total.." bị khóa"; FSub.TextColor3=C.t2; regrad(FR,C.rA,C.rB); tw(SDot,{BackgroundColor3=C.t2}); SLbl.Text="Chờ lệnh"; SLbl.TextColor3=C.t2; if not isMin then regrad(Panel,C.pA,C.pB) end
    end
end

local function toggleFreeze(status)
    if not npcFolder then SLbl.Text="⚠  Không thấy LocalNPCs"; SLbl.TextColor3=rgb(255,75,55); SDot.BackgroundColor3=rgb(255,75,55); return end
    local count=0; for _,npc in pairs(getNPCs()) do deepFreeze(npc,status); if status then count+=1 end end
    if not status then frozenData={} end; setFreezeUI(status,count)
end

FBtn.MouseButton1Click:Connect(function() isFrozen=not isFrozen; toggleFreeze(isFrozen) end)

RunService.Heartbeat:Connect(function()
    if not isFrozen or not npcFolder then return end
    for _,npc in pairs(getNPCs()) do
        local dHRP=npc:FindFirstChild("HumanoidRootPart")
        local isSimple=dHRP~=nil and npc:FindFirstChildOfClass("Humanoid")~=nil
        if isSimple then
            if (dHRP.Position-EXILE).Magnitude>500 then dHRP.CFrame=CFrame.new(EXILE) end
            dHRP.Velocity=Vector3.zero; dHRP.AssemblyLinearVelocity=Vector3.zero
        else
            for _,obj in pairs(npc:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Anchored then obj.Velocity=Vector3.zero; obj.RotVelocity=Vector3.zero; obj.AssemblyLinearVelocity=Vector3.zero; obj.AssemblyAngularVelocity=Vector3.zero end
            end
        end
        local hum=npc:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=0 end
    end
end)

-- ================================================================
-- PROXIMITY PROMPT — Clone
-- ================================================================
local ppOn=false; local ppClones={}; local PP_DIST=6

local function makeClone(orig)
    if ppClones[orig] then return end
    local part=orig.Parent; if not part or not part:IsA("BasePart") then return end
    local c=Instance.new("ProximityPrompt"); c.ActionText=orig.ActionText~="" and orig.ActionText or "Interact"; c.ObjectText=""; c.KeyboardKeyCode=Enum.KeyCode.Unknown; c.HoldDuration=orig.HoldDuration; c.MaxActivationDistance=PP_DIST; c.RequiresLineOfSight=false; c.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton; c.Name="PPClone_NpcCtrl"; c.Parent=part
    c.Triggered:Connect(function(plr) if plr==player then fireproximityprompt(orig) end end)
    ppClones[orig]=c
end
local function removeClone(orig) local c=ppClones[orig]; if c then c:Destroy(); ppClones[orig]=nil end end
local function refreshClones(show)
    if show then for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") and v.Name~="PPClone_NpcCtrl" then makeClone(v) end end
    else for orig in pairs(ppClones) do removeClone(orig) end; ppClones={} end
end
local function setPpUI(on)
    if on then
        regrad(PPTrack,C.vA,C.vB); PPRim.Color=rgb(55,15,135); tw(PPKnob,{Position=UDim2.new(1,-23,0.5,-10)}); regrad(PPKnob,rgb(248,244,255),rgb(198,180,240)); regrad(PPAcc,C.vA,C.vB); PPLbl.TextColor3=C.tV; PPSub.Text="Prompts mobile bật"; PPSub.TextColor3=rgb(155,105,240); regrad(PPR,rgb(22,12,42),rgb(12,6,22))
    else
        regrad(PPTrack,C.tOffA,C.tOffB); PPRim.Color=rgb(7,8,12); tw(PPKnob,{Position=UDim2.new(0,3,0.5,-10)}); regrad(PPKnob,C.kA,C.kB); regrad(PPAcc,C.t2,C.t2); PPLbl.TextColor3=C.t0; PPSub.Text="Clone prompt cho mobile"; PPSub.TextColor3=C.t2; regrad(PPR,C.rA,C.rB)
    end
end
PPBtn.MouseButton1Click:Connect(function()
    ppOn=not ppOn; refreshClones(ppOn); setPpUI(ppOn)
    local count=0; for _ in pairs(ppClones) do count+=1 end
    if ppOn then SLbl.Text="Prompts ON  ·  "..count.." clones"; SLbl.TextColor3=C.tV; tw(SDot,{BackgroundColor3=C.vB})
    else SLbl.Text="Chờ lệnh"; SLbl.TextColor3=C.t2; tw(SDot,{BackgroundColor3=C.t2}) end
end)
workspace.DescendantAdded:Connect(function(v) if ppOn and v:IsA("ProximityPrompt") and v.Name~="PPClone_NpcCtrl" then task.defer(function() makeClone(v) end) end end)
workspace.DescendantRemoving:Connect(function(v) if v:IsA("ProximityPrompt") and v.Name~="PPClone_NpcCtrl" then removeClone(v) end end)

-- ================================================================
-- AUTO FIRE EVENT (Row 3, loop riêng)
-- ================================================================
local autoOn=false

local function setAutoUI(on)
    if on then
        regrad(AFTrack,C.rdA,C.rdB); AFRim.Color=rgb(140,20,10); tw(AFKnob,{Position=UDim2.new(1,-23,0.5,-10)}); regrad(AFKnob,rgb(255,220,215),rgb(230,160,150)); regrad(AFAcc,C.rdA,C.rdB); AFLbl.TextColor3=rgb(255,160,145); AFSub.Text="Đang fire mỗi 1 giây"; AFSub.TextColor3=C.tR; regrad(AFR,rgb(36,12,10),rgb(20,6,5)); tw(SDot,{BackgroundColor3=C.rdB}); SLbl.Text="Auto Fire ON  ·  mỗi 1s"; SLbl.TextColor3=C.tR
    else
        regrad(AFTrack,C.tOffA,C.tOffB); AFRim.Color=rgb(7,8,12); tw(AFKnob,{Position=UDim2.new(0,3,0.5,-10)}); regrad(AFKnob,C.kA,C.kB); regrad(AFAcc,C.rdA,C.rdB); AFLbl.TextColor3=C.tR; AFSub.Text="NPCInteraction mỗi 1 giây"; AFSub.TextColor3=C.t2; regrad(AFR,C.rA,C.rB); tw(SDot,{BackgroundColor3=C.t2}); SLbl.Text="Chờ lệnh"; SLbl.TextColor3=C.t2
    end
end

AFBtn.MouseButton1Click:Connect(function()
    autoOn=not autoOn; setAutoUI(autoOn)
    if autoOn then
        fireNPCEvent()  -- fire ngay lần đầu
        task.spawn(function()
            while autoOn do task.wait(1); if autoOn then fireNPCEvent() end end
        end)
    end
end)

-- ================================================================
-- TELEPORT
-- ================================================================
local character=player.Character or player.CharacterAdded:Wait()
local initCF=character:WaitForChild("HumanoidRootPart").CFrame
local retCF=nil

local function setRbActive(on)
    if on then
        regrad(RR,C.rA,C.rB); regrad(RAcc,C.oA,C.oB); RLbl.TextColor3=C.tO; RSub.Text="Quay về vị trí trước"; RSub.TextColor3=C.t1
        RBtn.MouseEnter:Connect(function() regrad(RR,C.rHA,C.rHB) end); RBtn.MouseLeave:Connect(function() regrad(RR,C.rA,C.rB) end)
    else
        regrad(RR,C.rDA,C.rDB); regrad(RAcc,C.t2,C.t2); RLbl.TextColor3=C.t2; RSub.Text="Nhấn 'Về ban đầu' trước"; RSub.TextColor3=C.t2
    end
end
TBtn.MouseButton1Click:Connect(function()
    local char=player.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    retCF=hrp.CFrame; setRbActive(true); hrp.CFrame=initCF
    regrad(TR,C.bD,rgb(8,15,30)); TLbl.Text="✓  Đã về!"; tw(TLbl,{TextColor3=rgb(160,228,255)}); TSub.Text="Vị trí cũ → Return Back"
    task.delay(1.6,function() TLbl.Text="Về vị trí ban đầu"; tw(TLbl,{TextColor3=C.tB}); TSub.Text="Lưu vị trí → teleport"; regrad(TR,C.rA,C.rB) end)
end)
RBtn.MouseButton1Click:Connect(function()
    if not retCF then RSub.Text="⚠  Nhấn 'Về ban đầu' trước!"; task.delay(2,function() if not retCF then RSub.Text="Nhấn 'Về ban đầu' trước" end end); return end
    local char=player.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    hrp.CFrame=retCF; regrad(RR,C.oD,rgb(20,10,2)); RLbl.Text="✓  Đã quay về!"; tw(RLbl,{TextColor3=rgb(255,218,122)}); RSub.Text="Đã về vị trí đã lưu"
    task.delay(1.6,function() RLbl.Text="Return Back"; tw(RLbl,{TextColor3=C.tO}); RSub.Text="Quay về vị trí trước"; regrad(RR,C.rA,C.rB) end)
end)

-- ================================================================
-- FLOATING BUTTON — ScreenGui riêng, fire NPCInteraction 1 lần
-- Vị trí góc phải màn hình, có UIDragDetector
-- ================================================================
local FloatGui=Instance.new("ScreenGui"); FloatGui.Name="NpcFireFloat"; FloatGui.Parent=game.CoreGui; FloatGui.ResetOnSpawn=false; FloatGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local FB=Instance.new("Frame"); FB.Parent=FloatGui; FB.Size=UDim2.new(0,72,0,72); FB.Position=UDim2.new(1,-96,0.5,-36); FB.BackgroundColor3=rgb(20,22,34); FB.BorderSizePixel=0; FB.Active=true; FB.ZIndex=10; corner(FB,36); grad(FB,rgb(38,40,62),rgb(12,13,20))
local fbRim=Instance.new("UIStroke"); fbRim.Color=rgb(255,90,65); fbRim.Thickness=2; fbRim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; fbRim.Parent=FB

local FBIcon=Instance.new("TextLabel"); FBIcon.Parent=FB; FBIcon.Size=UDim2.new(1,0,0,32); FBIcon.Position=UDim2.new(0,0,0,10); FBIcon.BackgroundTransparency=1; FBIcon.Text="⚡"; FBIcon.TextSize=24; FBIcon.Font=Enum.Font.Gotham; FBIcon.TextXAlignment=Enum.TextXAlignment.Center; FBIcon.ZIndex=11

local FBLbl=Instance.new("TextLabel"); FBLbl.Parent=FB; FBLbl.Size=UDim2.new(1,0,0,16); FBLbl.Position=UDim2.new(0,0,1,-20); FBLbl.BackgroundTransparency=1; FBLbl.Text="FIRE"; FBLbl.TextSize=9; FBLbl.Font=Enum.Font.GothamBold; FBLbl.TextColor3=rgb(255,140,120); FBLbl.TextXAlignment=Enum.TextXAlignment.Center; FBLbl.ZIndex=11

local FBDrag=Instance.new("UIDragDetector"); FBDrag.ResponseStyle=Enum.UIDragDetectorResponseStyle.Offset; FBDrag.DragStyle=Enum.UIDragDetectorDragStyle.TranslatePlane; FBDrag.Parent=FB

local FBBtn=Instance.new("TextButton"); FBBtn.Parent=FB; FBBtn.Size=UDim2.new(1,0,1,0); FBBtn.BackgroundTransparency=1; FBBtn.Text=""; FBBtn.ZIndex=12

local fbCD=false
FBBtn.MouseButton1Click:Connect(function()
    if fbCD then return end; fbCD=true
    fireNPCEvent()
    regrad(FB,rgb(220,55,35),rgb(140,18,8)); fbRim.Color=rgb(255,210,200); FBLbl.Text="✓"
    task.delay(0.35,function() regrad(FB,rgb(38,40,62),rgb(12,13,20)); fbRim.Color=rgb(255,90,65); FBLbl.Text="FIRE"; fbCD=false end)
end)
FBBtn.MouseEnter:Connect(function() if not fbCD then regrad(FB,rgb(50,52,80),rgb(18,19,32)) end end)
FBBtn.MouseLeave:Connect(function() if not fbCD then regrad(FB,rgb(38,40,62),rgb(12,13,20)) end end)
