-- hpnsible
-- 200530
--
-- step sequencer
-- selected randomness
-- based on parc by tehn
--
-- requires: norns, grid, crow
-- & ansible in teletype expander mode
--
-- crow outs:
--  none
--  
-- norns controls:
--  ENC 1 = scroll top menu
--  ENC 2 = select parameter 
--  ENC 3 = set selected parameter
--   columns left to right 
--    are lanes 1 to 4
--  KEY 2 or 3 toggles between grid
--   loop/cut/rate page
--   and main triggers pages
--
-- grid controls:
-- main
--  top row (left to right):
--    1 > 4 tracks
--    9 > 12 notes, divs, 
--    octaves, probability mutes
--  mutes page
--   from top of column down:
--    0%, 25%, 50%, 75%, 100%
--    chance for a trigger to mute
--
--  all other page rows toggle triggers
--  of the selected page+option
--
-- loop/cut/rate
--  row 1 > 4 
--   single press/release 'jump to'
--   double press sets loop
--  row 5 > 6
--   set track rate
--
-- No note mutes for a step
-- No div' selected defaults to a 
-- normal step rest
-- No octave selected defaults 0
--
-- PARAMS
-- Track 1 - 4:
--  1 sends crow trig on loop start
--  0 send crow trig every step,
--  regardless of mute


  ------- main settings tables
  globalrates = {4,3,2,1,0.5,0.3333,0.25,0.125,1,1.1,1.2,1.3,1.4,1.5,1.6,1.7} -- open to changing these, make setable?
  
  a = {15,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1} -- highlted norns menu table
  divslist = {1,2,3,4,5,6,7,8} 
  convert = {1,0.5,0.333333333,0.25,0.2,0.1667,0.1428,0.125} --whole,half,triplet,quarter note etc upto eightnotes

  noteslist = {"C0","C#0","D0","D#0","E0","F0","F#0","G0","G#0","A0","A#0","B0","C1","C#1","D1","D#1","E1","F1","F#1","G1","G#1","A1","A#1","B1",
              "C2","C#2","D2","D#2","E2","F2","F#2","G2","G#2","A2","A#2","B2","C3","C#3","D3","D#3","E3","F3","F#3","G3","G#3","A3","A#3","B3",
                "C4","C#4","D4","D#4","E4","F4","F#4","G4","G#4","A4","A#4","B4","C5","C#5","D5","D#5","E5","F5","F#5","G5","G#5","A5","A#5","B5"}
  
  
  pitch = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,
            25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,
              49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72} -- hard coded, dont change
            
  octaveslist = {0,1,2,3,4,5,6,7}
  pulses = {.005,.010,.020,.030,.040,.050,.060,.070,.080,.090,.1,.15,.2,.25,.3,.4} -- not really used at the moment (old table for crow only version)
  ntblname = {"notes","divs","octaves","global"}
  gridsubname = {"notes","divs","octaves","mutes","global"}
  
  -------- per track tables
  notes1 = {}
  divs1 = {}
  octaves1 = {}
  mutes1 = {}
  selectednotes1 = {0,4,5,7,9,11,11} -- set via norns ui
  selecteddivs1 = {1,2,3,4,5,6,8} --tables can only be 7 long
  selectedoctaves1 = {0,1,2,3,4,5,6} --  
  
  notes2 = {}
  divs2 = {}
  octaves2 = {}
  mutes2 = {}
  selectednotes2 = {0,4,5,7,9,11,11} 
  selecteddivs2 = {1,2,3,4,5,6,8} 
  selectedoctaves2 = {0,1,2,3,4,5,6} 
  
  notes3 = {}
  divs3 = {}
  octaves3 = {}
  mutes3 = {}
  selectednotes3 = {0,4,5,7,9,11,11} 
  selecteddivs3 = {1,2,3,4,5,6,8} 
  selectedoctaves3 = {0,1,2,3,4,5,6} 
  
  notes4 = {}
  divs4 = {}
  octaves4 = {}
  mutes4 = {}
  selectednotes4 = {0,4,5,7,9,11,11} 
  selecteddivs4 = {1,2,3,4,5,6,8} 
  selectedoctaves4 = {0,1,2,3,4,5,6} 

  g = grid.connect()
  
function init()
  for i=1,16 do
      notes1[i] = {}
      notes2[i] = {}
      notes3[i] = {}
      notes4[i] = {}
      divs1[i] = {}
      divs2[i] = {}
      divs3[i] = {}
      divs4[i] = {}
      octaves1[i] = {}
      octaves2[i] = {}
      octaves3[i] = {}
      octaves4[i] = {}
    for j=2,8 do
        notes1[i][j] = 0
        notes2[i][j] = 0
        notes3[i][j] = 0
        notes4[i][j] = 0
        divs1[i][j] = 0
        divs2[i][j] = 0
        divs3[i][j] = 0
        divs4[i][j] = 0
        octaves1[i][j] = 0
        octaves2[i][j] = 0
        octaves3[i][j] = 0
        octaves4[i][j] = 0
      for k=1,16 do
          --notes1[i][2] = 1
          --notes2[i][2] = 1
          --notes3[i][2] = 1
          --notes4[i][2] = 1
          divs1[i][2] = 1
          divs2[i][2] = 1
          divs3[i][2] = 1
          divs4[i][2] = 1
          octaves1[i][2] = 1
          octaves2[i][2] = 1
          octaves3[i][2] = 1
          octaves4[i][2] = 1
      end
    end
  end
  
  for i = 1,16 do
    mutes1[i] = {}
    mutes2[i] = {}
    mutes3[i] = {}
    mutes4[i] = {}
    for j = 2,6 do
      mutes4[i][j] = 0
      mutes2[i][j] = 0
      mutes3[i][j] = 0
      mutes4[i][j] = 0
      for k = 1,16 do
        mutes1[i][2] = 1
        mutes2[i][2] = 1
        mutes3[i][2] = 1
        mutes4[i][2] = 1
      end
    end
  end
  ------------- per track settings
  i1 = 0
  io1 = 1
  length1 = 16
  offset1 = 1
  check1 = {}
  loopmin1 = 1
  loopmax1 = 16
  keycount1 = 0
  live1 = 1
  lednotes1 = 0
  leddivs1 = 0
  ledoctaves1 = 0
  ledmutes1 = 0
  usemedivs1 = 1
  usemenotes1 = 1
  usemeoctaves1 = 1
  usememutes1 = 1
  masterrate1 = 1
  rateindex1 = 4
  --volts1 = 0        --- previous crow only inits
  --slew1 = 0.01
  --setpulse1 = .005
  --pulseindex1 = 1
  --pulse1 = "pulse("..setpulse1..",5,1)" 
  
  
  i2 = 0
  io2 = 1
  length2 = 16
  offset2 = 1
  check2 = {}
  loopmin2 = 1
  loopmax2 = 16
  keycount2 = 0
  live2 = 1
  lednotes2 = 0
  leddivs2 = 0
  ledoctaves2 = 0
  ledmutes2 = 0
  usemedivs2 = 1
  usemenotes2 = 1
  usemeoctaves2 = 1
  usememutes2 = 1
  masterrate2 = 1  -- 2 = slower 0.5 = faster etc
  rateindex2 = 4
  --volts2 = 0
  --slew2 = 0.01
  --setpulse2 = .005
  --pulseindex2 = 1
  --pulse2 = "pulse("..setpulse2..",5,1)"
  
  i3 = 0
  io3 = 1
  length3 = 16
  offset3 = 1
  check3 = {}
  loopmin3 = 1
  loopmax3 = 16
  keycount3 = 0
  live3 = 1
  lednotes3 = 0
  leddivs3 = 0
  ledoctaves3 = 0
  ledmutes3 = 0
  usemedivs3 = 1
  usemenotes3 = 1
  usemeoctaves3 = 1
  usememutes3 = 1
  masterrate3 = 1 
  rateindex3 = 4
  --volts3 = 0
  --slew3 = 0.01
  --setpulse3 = .005
  --pulseindex3 = 1
  --pulse3 = "pulse("..setpulse3..",5,1)"
  
  i4 = 0
  io4 = 1
  length4 = 16
  offset4 = 1
  check4 = {}
  loopmin4 = 1
  loopmax4 = 16
  keycount4 = 0
  live4 = 1
  lednotes4 = 0
  leddivs4 = 0
  ledoctaves4 = 0
  ledmutes4 = 0
  usemedivs4 = 1
  usemenotes4 = 1
  usemeoctaves4 = 1
  usememutes4 = 1
  masterrate4 = 1  
  rateindex4 = 4
  --volts4 = 0
  --slew4 = 0.01
  --setpulse4 = .005
  --pulseindex4 = 1
  --pulse4 = "pulse("..setpulse4..",5,1)"
  
  ------------ general inits
  page = 1
  subpage = 9
  tblname = "notes"
  ioset = io1
  pospage = notes1
  posreturn = lednotes1
  
  npage =  1 -------------------------------- -----------norns releated inits
  enc2 = 1
  enc3 = 1
  go = 0
  ntbldisplay = "notes" -- used for returning enc value correctly/which table its pointing at, when navigating norns
  ncol = 1
  nfindtbl = ("selected"..ntbldisplay..ncol)
  nlist = ntbldisplay.."list"
  ntbl = "selected"..ntbldisplay
  nwherewasi = subpage
  params:add_number("tempo","tempo",20,240,88)
  params:add_number("step/reset1","step/reset1",0,1,1)
  params:add_number("step/reset2","step/reset2",0,1,1)
  params:add_number("step/reset3","step/reset3",0,1,1)
  params:add_number("step/reset4","step/reset4",0,1,1)----------

  crow.ii.pullup(true)

  grid_redraw()
end



function getrandom(track,tbltype)
  local temptbl = {}
  local iftbl = tbltype..track
  local seltbl = "selected"..iftbl
  local usetbl = "useme"..iftbl
  local ledtbl = "led"..iftbl
  local i = "io"..track
  local returnvalue = 0 
  
  for c = 2,8 do
    if _G[iftbl][_G[i]][c] == 1 then
      table.insert(temptbl,c)
    end
  end
  
  if #temptbl > 0 then
    q = math.random (1,#temptbl) --generate a random number, based on the table length
    _G[usetbl] = _G[seltbl][(temptbl[q] - 1)] 
    _G[ledtbl] = temptbl[q]      
    for w = 1,#temptbl do  
      temptbl[w] = nil    
    end
    returnvalue = _G[usetbl]
  else
    returnvalue = "no"
  end
  return returnvalue
end



function randommute(track)
  local prob = {{1,1,1,1},{1,1,1,0},{1,1,0,0},{1,0,0,0},{0,0,0,0}}
  local p = math.random(1,4)
  local ptbl = "mutes"..track
  local i = "io"..track
  
  for c = 2,6 do
    if _G[ptbl][_G[i]][c] == 1 then
     this = c - 1
    end
  end
  
  local play = prob[this][p]
  
  return play
end

function crowout(track,step)
  local t = track
  local s = step
  local SR = "step/reset"..t  
  local howoften = params:get(SR)

  if howoften == 1 then
    if s == 1 then
    crow.output[t].action = "pulse(.005,5,1)" 
    crow.output[t].execute()
    end
  elseif howoften == 0 then
    crow.output[t].action = "pulse(.005,5,1)" 
    crow.output[t].execute()
  end
end



function first()
  clock.sync(1) -- waits to start, to be in sync
  while go==1 do 
    i1 = (i1 % length1) + 1 --counter for loop length (2 to 16)
    io1 = i1 + (offset1 - 1) -- offset for loopstart/where play head actually is/should be
    
    crowout(1,i1) -- send trigger out of crow 1 (track number, count of iTRACK)
    
    local div = getrandom(1,"divs")  -- how many times are we doing the below for loop (track number, begining of table set)
    if div == "no" then
      usemedivs1 = 1; leddivs1 = 2
    end
    
    for d = 1,usemedivs1 do   -- do the below however many times
      
      local note = getrandom(1,"notes") -- which note on this occasion?
      if note == "no" then
        live1 = 0; lednotes1 = 2 -- if none, we wont change pitch or send ansible trigger . led default to row 2 to show playhead progress
      else live1 = 1
      end
      
      local oct = getrandom(1,"octaves") -- octave shift it?
      if oct == "no" then
        usemeoctaves1 = 0 ; ledoctaves1 = 2 -- defaults to zero
      end
      
      if live1 == 1 then     --- shall we maybe make a division silent ?
        local mute = randommute(1)
        live1 = mute
      end
      
      if usemedivs1 > 1 and live1 == 1 then  -- make noises (if conditions are met), and have a defined rest
        makenoise(1)
        grid_redraw()
        clock.sync((convert[usemedivs1] * masterrate1))
      elseif usemedivs1 == 1 and live1 == 1 then
        makenoise(1)
        grid_redraw()
        clock.sync(masterrate1)
      elseif usemedivs1 > 1 and live1 == 0 then
        grid_redraw()
        clock.sync((convert[usemedivs1] * masterrate1))
      elseif usemedivs1 == 1 and live1 == 0 then
        grid_redraw()
        clock.sync(masterrate1)
      else
        grid_redraw()
        clock.sync(masterrate1)
      end
    end
  end
end


function second()
  clock.sync(1)
  while go==1 do
    i2 = (i2 % length2) + 1
    io2 = i2 + (offset2 - 1)
    
    crowout(2,i2)
    
    local div = getrandom(2,"divs")
    if div == "no" then
      usemedivs2 = 1; leddivs2 = 2
    end
    
    for d = 1,usemedivs2 do
      
      local note = getrandom(2,"notes")
      if note == "no" then
        live2 = 0; lednotes2 = 2
      else live2 = 1
      end
      
      local oct = getrandom(2,"octaves")
      if oct == "no" then
        usemeoctaves2 = 0; ledoctaves2 = 2
      end
      
      if live2 == 1 then
        local mute = randommute(2)
        live2 = mute
      end
      
      if usemedivs2 > 1 and live2 == 1 then
        makenoise(2)
        grid_redraw()
        clock.sync((convert[usemedivs2] * masterrate2))
      elseif usemedivs2 == 1 and live2 == 1 then
        makenoise(2)
        grid_redraw()
        clock.sync(masterrate2)
      elseif usemedivs2 > 1 and live2 == 0 then
        grid_redraw()
        clock.sync((convert[usemedivs2] * masterrate2))
      elseif usemedivs2 == 1 and live2 == 0 then
        grid_redraw()
        clock.sync(masterrate2)
      else
        grid_redraw()
        clock.sync(masterrate2)
      end
    end
  end
end

function third()
  clock.sync(1)
  while go==1 do
    i3 = (i3 % length3) + 1
    io3 = i3 + (offset3 - 1)
    
    crowout(3,i3)
    
    local div = getrandom(3,"divs")
    if div == "no" then
      usemedivs3 = 1; leddivs3 = 2
    end
    
    for d = 1,usemedivs3 do
      
      local note = getrandom(3,"notes")
      if note == "no" then
        live3 = 0; lednotes3 = 2
      else live3 = 1
      end
      
      local oct = getrandom(3,"octaves")
      if oct == "no" then
        usemeoctaves3 = 0; ledoctaves3 = 2
      end
      
      if live3 == 1 then
        local mute = randommute(3)
        live3 = mute
      end
      
      if usemedivs3 > 1 and live3 == 1 then
        makenoise(3)
        grid_redraw()
        clock.sync((convert[usemedivs3] * masterrate3))
      elseif usemedivs3 == 1 and live3 == 1 then
        makenoise(3)
        grid_redraw()
        clock.sync(masterrate3)
      elseif usemedivs3 > 1 and live3 == 0 then
        grid_redraw()
        clock.sync((convert[usemedivs3] * masterrate3))
      elseif usemedivs3 == 1 and live3 == 0 then
        grid_redraw()
        clock.sync(masterrate3)
      else
        grid_redraw()
        clock.sync(masterrate3)
      end
    end
  end
end

function forth()
  clock.sync(1)
  while go==1 do
    i4 = (i4 % length4) + 1 
    io4 = i4 + (offset4 - 1)
    
    crowout(4,i4)
    
    local div = getrandom(4,"divs")
    if div == "no" then
      usemedivs4 = 1; leddivs4 = 2
    end
    
    for d = 1,usemedivs4 do
      local note = getrandom(4,"notes")
      if note == "no" then
        live4 = 0; lednotes4 = 2
      else live4 = 1      
      end
        
      local oct = getrandom(4,"octaves")
      if oct == "no" then
        usemeoctaves4 = 0; ledoctaves4 = 2
      end
        
      if live4 == 1 then
        local mute = randommute(4)
        live4 = mute
      end
      
      if usemedivs4 > 1 and live4 == 1 then
        makenoise(4)
        grid_redraw()
        clock.sync((convert[usemedivs4] * masterrate4))
      elseif usemedivs4 == 1 and live4 == 1 then
        makenoise(4)
        grid_redraw()
        clock.sync(masterrate4)
      elseif usemedivs4 > 1 and live4 == 0 then
        grid_redraw()
        clock.sync((convert[usemedivs4] * masterrate4))
      elseif usemedivs4 == 1 and live4 == 0 then
        grid_redraw()
        clock.sync(masterrate4)
      else
        grid_redraw()
        clock.sync(masterrate4)
      end
    end
  end
end


function makenoise(track)
  local mnnotes = "usemenotes"..track
  local mnoctaves = "usemeoctaves"..track
  
  v = (0.08333333 * _G[mnnotes]) + (1 * _G[mnoctaves])
  crow.ii.ansible.trigger_time( track, 5 )
  crow.ii.ansible.trigger_pulse( track )
  crow.ii.ansible.cv(track,v)
end

------------------------------------------------------------ norns i/o below 

function key(n,z)
  if z == 1 and n == 3 or z == 1 and n == 2 then
    if subpage ~= 16 then
      nwherewasi = subpage
      subpage = 16
      grid_redraw()
    elseif subpage == 16 then 
      subpage = nwherewasi
      grid_redraw()    
    end
  end
end


function npagecount(move)
  if move == 1 then
    if npage >= 4 then
      npage = 1
    else  
      npage = npage + 1
    end
    elseif move == -1 then
    if npage <= 1 then
      npage = 4
    else  
      npage = npage - 1
    end
  end
  ntbldisplay = ntblname[npage]
  redraw()
end



function enc(n,d)
  if d > 0 then
    dinc = 1
    if n == 1 then npagecount(1) end
  elseif d < 0 then
      dinc = -1
      if n == 1 then npagecount(-1) end
  end
  
  nfindtbl = ("selected"..ntbldisplay..ncol)
  if n == 1 then
    if ntblname[npage] == "notes" or ntblname[npage] == "octaves" then  ---------------geta enc3 value on page change
      if enc2 <= 7 then
        enc3 = _G[nfindtbl][enc2] + 1
      elseif enc2 >= 8 and enc2 <= 14 then
        enc3 = _G[nfindtbl][enc2 - 7] + 1
      elseif enc2 >= 15 and enc2 <=21 then
        enc3 = _G[nfindtbl][enc2 - 14] + 1
      elseif enc2 >=22 and enc2 <=28 then
        enc3 = _G[nfindtbl][enc2 - 21] + 1
      end
    end
    if ntblname[npage] == "divs" then
      if enc2 <= 7 then
        enc3 = _G[nfindtbl][enc2]
      elseif enc2 >= 8 and enc2 <= 14 then
        enc3 = _G[nfindtbl][enc2 - 7]
      elseif enc2 >= 15 and enc2 <= 21 then
        enc3 = _G[nfindtbl][enc2 - 14]
      elseif enc2 >=22 and enc2 <= 28 then
        enc3 = _G[nfindtbl][enc2 - 21]
      end
    end
  end -- -----------------------------------------------------------------------------------
  
  if npage == 1 then
    if n == 3 then
      enc3 = enc3 + dinc
      check = enc3
      if check > 72 then
        enc3 = 1
      elseif check < 1 then
        enc3 = 72
      else
      end
      if enc2 >=22 and enc2 <=28 then
        ncol = 4
        selectednotes4[enc2 - 21] = pitch[enc3]
        redraw()
      elseif enc2 >=15 and enc2 <=21 then
        ncol = 3
        selectednotes3[enc2 - 14] = pitch[enc3]
        redraw()
      elseif enc2 >=8 and enc2 <=14 then
        ncol = 2
        selectednotes2[enc2 - 7] = pitch[enc3]
        redraw()
      elseif enc2 <=7 then
        ncol = 1
        selectednotes1[enc2] = pitch[enc3]
        redraw()
      end
    elseif n == 2 then
      enc2 = enc2 + dinc
      check = enc2
      if check > 28 then
        enc2 = 1
      elseif check < 1 then
        enc2 = 28
      else
      end
      if enc2 >=22 and enc2 <= 28 then
        ncol = 4
        enc3 = (selectednotes4[enc2 - 21]) + 1
        redraw()
      elseif enc2 >=15 and enc2 <= 21 then
        ncol = 3
        enc3 = (selectednotes3[enc2 - 14]) + 1
        redraw() 
      elseif enc2 >=8 and enc2 <= 14 then
        ncol = 2
        enc3 = (selectednotes2[enc2 - 7]) + 1
        redraw()
      elseif enc2 <=7 then
        ncol = 1
        enc3 = (selectednotes1[enc2]) + 1
        redraw()
      end
      for highlighted = 1,28 do
          a[highlighted] = 1
      end
      a[enc2] = 15
      redraw()
    end
  end
   
   
    
if npage == 2 then
    if n == 3 then
      enc3 = enc3 + dinc
      check = enc3
      if check > 8 then
        enc3 = 1
      elseif check < 1 then
        enc3 = 8
      else
      end
      if enc2 >=22 and enc2 <=28 then
        ncol = 4
        selecteddivs4[enc2 - 21] = divslist[enc3]
        redraw()
      elseif enc2 >=15 and enc2 <=21 then
        ncol = 3
        selecteddivs3[enc2 - 14] = divslist[enc3]
        redraw()
      elseif enc2 >=8 and enc2 <= 14then
        ncol = 2
        selecteddivs2[enc2 - 7] = divslist[enc3]
        redraw()
      elseif enc2 <=7 then
        ncol = 1
        selecteddivs1[enc2] = divslist[enc3]
        redraw()
      end
    elseif n == 2 then
      enc2 = enc2 + dinc
      check = enc2
      if check > 28 then
        enc2 = 1
      elseif check < 1 then
        enc2 = 28
      else
      end
      if enc2 >=22 and enc2 <= 28 then
        ncol = 4
        enc3 = (selecteddivs4[enc2 - 21]) --+ 1
        redraw()
      elseif enc2 >=15 and enc2 <= 21 then
        ncol = 3
        enc3 = (selecteddivs3[enc2 - 14]) --+ 1
        redraw()
      elseif enc2 >=8 and enc2 <=14 then
        ncol = 2
        enc3 = (selecteddivs2[enc2 - 7]) --+ 1
        redraw()
      elseif enc2 <=7 then
        ncol = 1
        enc3 = (selecteddivs1[enc2]) --+ 1
        redraw()
      end
      for highlighted = 1,28 do
          a[highlighted] = 1
      end
      a[enc2] = 15
      redraw()
    end   
  end
  
  
  if npage == 3 then
    if n == 3 then
      enc3 = enc3 + dinc
      check = enc3
      if check > 8 then  --menu scroller
        enc3 = 1
      elseif check < 1 then
        enc3 = 8
      else
      end
      if enc2 >=22 and enc2 <=28 then
        ncol = 4
        selectedoctaves4[enc2 - 21] = octaveslist[enc3]
        redraw()
      elseif enc2 >= 15 and enc2 <= 21 then
        ncol = 2
        selectedoctaves3[enc2 - 14] = octaveslist[enc3]
        redraw()
      elseif enc2 >=8 and enc2 <=14 then
        ncol = 2
        selectedoctaves2[enc2 - 7] = octaveslist[enc3]
        redraw()
      elseif enc2 <=7 then
        ncol = 1
        selectedoctaves1[enc2] = octaveslist[enc3]
        redraw()
      end
    elseif n == 2 then
      enc2 = enc2 + dinc
      check = enc2
      if check > 28 then
        enc2 = 1
      elseif check < 1 then
        enc2 = 28
      else
      end
      if enc2 >=22 and enc2 <=28 then
        ncol = 4
        enc3 = (selectedoctaves4[enc2 - 21]) + 1
        redraw()
      elseif enc2 >=15 and enc2 <=21 then
        ncol = 3
        enc3 = (selectedoctaves3[enc2 - 14]) + 1
        redraw()     
      elseif enc2 >=8 and enc2 <=14 then
        ncol = 2
        enc3 = (selectedoctaves2[enc2 - 7]) + 1
        redraw()
      elseif enc2 <=7 then
        ncol = 1
        enc3 = (selectedoctaves1[enc2]) + 1
        redraw()
      end
      for highlighted = 1,28 do
          a[highlighted] = 1
      end
      a[enc2] = 15
      redraw()
    end  
  end
  
  if npage == 4 then 
    if n == 3 and dinc > 0 and go == 0 then
      if go == 0 then -- extra check to make double space play head happen less
        go = 1 -- needed before clock run?
      end
      lane1 = clock.run(first)
      lane2 = clock.run(second)
      lane3 = clock.run(third)
      lane4 = clock.run(forth)
    print("playing")
    redraw()
    elseif n ==3 and dinc < 0 and go == 1 then
      clock.cancel(lane1)
      clock.cancel(lane2)
      clock.cancel(lane3)
      clock.cancel(lane4)
      go = 0
      i1 = 0; i2 = 0; i3 = 0; i4 = 0
      io1 = 1; io2 = 1; io3 = 1; io4 = 1
      enc3 = 1 
      print("stopped")
      redraw()
      grid_redraw()
    elseif n == 2 then
      params:set("tempo", (clock.get_tempo()))
      params:delta("tempo", d)
      params:set("clock_tempo",(params:get("tempo")))
      redraw()
    end
  end
end



function redraw()
  
  gl = 15; hl = 2; il = 2; jl = 2

  if npage == 1 then
    gl = 15;  hl = 2;   il = 2;   jl = 2
  elseif npage == 2 then
    gl = 2;   hl = 15;  il = 2;   jl = 2
  elseif npage == 3 then
    gl = 2;   hl = 2;   il = 15;  jl = 2
  elseif npage == 4 then
    gl = 2;   hl = 2;   il = 2;   jl = 15
  end
        
  screen.clear()
  screen.move(10,7)----------------
  screen.level(gl)
  screen.text("notes")
  screen.move(40,7)
  screen.level(hl)------------This bit draws the top menu bar
  screen.text("divs")
  screen.move(63,7)
  screen.level(il)
  screen.text("octaves")
  screen.move(102,7)
  screen.level(jl)
  screen.text("play")--------------------

  nlist = ntbldisplay.."list" 
  ntbl = "selected"..ntbldisplay

  if ntblname[npage] == "notes" or ntblname[npage] == "octaves" then
    for r = 1,4 do
    if r == 1 then e = 20; s = 0 end
    if r == 2 then e = 49; s = 7 end
    if r == 3 then e = 78; s = 14 end
    if r == 4 then e = 105; s = 21 end
    nfinaltbl = (ntbl)..r
    screen.move(e,14)
    screen.level(a[(1+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][1] + 1)])
    screen.move(e,22)
    screen.level(a[(2+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][2] + 1)])
    screen.move(e,30)
    screen.level(a[(3+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][3] + 1)])
    screen.move(e,38)
    screen.level(a[(4+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][4] + 1)])
    screen.move(e,46)
    screen.level(a[(5+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][5] + 1)])
    screen.move(e,54)
    screen.level(a[(6+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][6] + 1)])
    screen.move(e,62)
    screen.level(a[(7+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][7] + 1)])
    screen.update()
    end
  end
  
  if ntblname[npage] == "divs" then
    for r = 1,4 do
    if r == 1 then e = 20; s = 0 end
    if r == 2 then e = 49; s = 7 end
    if r == 3 then e = 78; s = 14 end
    if r == 4 then e = 105; s = 21 end
    nfinaltbl = (ntbl)..r
    screen.move(e,14)
    screen.level(a[(1+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][1])])
    screen.move(e,22)
    screen.level(a[(2+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][2])])
    screen.move(e,30)
    screen.level(a[(3+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][3])])
    screen.move(e,38)
    screen.level(a[(4+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][4])])
    screen.move(e,46)
    screen.level(a[(5+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][5])])
    screen.move(e,54)
    screen.level(a[(6+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][6])])
    screen.move(e,62)
    screen.level(a[(7+s)])
    screen.text(_G[nlist][(_G[nfinaltbl][7])])
    screen.update()
    end
  end
  
  if npage == 4 then
    
      screen.move(47,28)
      screen.level(14)
      screen.font_size(8)
      screen.text(clock.get_tempo().." bpm")

    if go == 0 then  
      screen.move(30,49)
      screen.level(15)
      screen.font_size(8)
      screen.text("stopped")
      screen.move(68,49)
      screen.level(1)
      screen.font_size(8)
      screen.text("playing")
    elseif go == 1 then
      screen.move(30,49)
      screen.level(1)
      screen.font_size(8)
      screen.text("stopped")
      screen.move(68,49)
      screen.level(15)
      screen.font_size(8)
      screen.text("playing") 
    end
    screen.update()
  end
end

------------------------------------------------------------------------- grid i/o below here 
g.key = function(x,y,z)
  if subpage ~= 16 then
    if y == 1 then 
      if x == 1 or x == 2 or x == 3 or x == 4  then
        page = x
        grid_redraw()
      elseif x == 9 or x == 10 or x == 11 or x == 12 then
        subpage = x
        tblname = gridsubname[x - 8]
        nwherewasi = subpage
        grid_redraw()
      end
    end
 
    gridtbl = tblname..page
    
    if z == 1 and y ~= 1 then
      if subpage == 12  then
        for i = 2,6 do
          _G[gridtbl][x][i] = 0
        end
        _G[gridtbl][x][y] = 1
        grid_redraw()
      elseif subpage ~= 12 or subpage ~= 16 then
        if _G[gridtbl][x][y] == 0 then
          _G[gridtbl][x][y] = 1
          grid_redraw()
        elseif _G[gridtbl][x][y] == 1 then
          _G[gridtbl][x][y] = 0
          grid_redraw()
        end
      end
    end
  end
  
  if subpage == 16 then  
    
    keycount = "keycount"..y
    check = "check"..y
    loopmin = "loopmin"..y
    loopmax = "loopmax"..y
    length = "length"..y
    offset = "offset"..y
    i = "i"..y

    if y == 1 or y == 2 or y == 3 or y == 4 then
      if _G[keycount] == 1 then
        _G[check][2] = x
        _G[keycount] = 0
      elseif _G[keycount] == 0 and z == 1 then
        _G[check][1] = x
        _G[keycount] = 1
      end

      if _G[check][1] ~= nil and _G[check][2] ~= nil then
        if _G[check][1] == _G[check][2] then
          _G[i] = (_G[check][1] - _G[offset])
          for w = 1,#_G[check] do
            _G[check][w] = nil
          end 
          grid_redraw()
        elseif _G[check][1] ~= _G[check][2] then
         _G[loopmin] = math.min(_G[check][1],_G[check][2])
          _G[loopmax] = math.max(_G[check][1],_G[check][2])
          _G[length] = (_G[loopmax] - _G[loopmin]) + 1
          _G[offset] = _G[loopmin]
          _G[i] = 0
          grid_redraw()
          for w = 1,#_G[check] do
            _G[check][w] = nil
          end 
        end
      end
    end

    if y == 5 and z == 1 then
        masterrate1 = globalrates[x]
        rateindex1 = x
        grid_redraw()
    end
    
    if y == 6 and z == 1 then
        masterrate2 = globalrates[x]
        rateindex2 = x
        grid_redraw()
    end
    
    if y == 7 and z == 1 then
       masterrate3 = globalrates[x]
       rateindex3 = x
       grid_redraw()
    end
    
   if y == 8 and z == 1 then
      masterrate4 = globalrates[x]
      rateindex4 = x
      grid_redraw()
    end
  end
end



function grid_redraw()
  g:all(0)
  
  if subpage == 16 then
    for lp1=loopmin1,loopmax1 do
        z=1
        g:led(lp1,1,z*5)
        g:led(io1,1,15)
    end
    for lp2=loopmin2,loopmax2 do
        z=1
        g:led(lp2,2,z*5)
        g:led(io2,2,15)
    end
    for lp3=loopmin3,loopmax3 do
      z=1
      g:led(lp3,3,z*5)
      g:led(io3,3,15)
    end
    for lp4=loopmin4,loopmax4 do
      z=1
      g:led(lp4,4,z*5)        
      g:led(io4,4,15)
    end
    g:led(rateindex1,5,10)
    g:led(rateindex2,6,10)
    g:led(rateindex3,7,10)
    g:led(rateindex4,8,10)
  end
  
  pospage = tblname..(page) 
  ioset = "io"..page
  posreturn = "led"..pospage
    
  if subpage == 9 or subpage == 10 or subpage == 11 then
    for i = 1,16 do
      for j = 2,8 do
        if _G[pospage][i][j] == 1 then
          z=1
          g:led(i,j,z*8)
        end
      end
    end
    g:led(_G[ioset],_G[posreturn],15)
  end
    
  if subpage == 12 then
    for i = 1,16 do
      for j = 2,6 do
        g:led(i,j,5)
        if _G[pospage][i][j] == 1 then
          g:led(i,j,10)
        end
      end
    end
    g:led(_G[ioset],2,15)
  end
    
    
  if subpage ~= 16 then  
    for k =1,4 do
      g:led(k,1,5)
    end
    for l = 9,12 do
      g:led(l,1,5)
    end
    g:led((page),1,15)
    g:led((subpage),1,15)  
  end
  g:refresh()
end
