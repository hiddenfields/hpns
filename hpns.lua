-- hpns
-- 200520
--
-- step sequencer
-- selected randomness
-- based on parc by tehn
--
-- requires: norns, grid, crow
--
-- crow outs:
--  out 1 = track 1 pitch voltage
--  out 2 = track 1 trigger/gate
--  out 3 = track 2 pitch voltage
--  out 4 = track 2 trigger/gate
--
-- norns controls:
--  K2 = page left
--  K3 = page right
--  ENC 2 = select parameter 
--  ENC 3 = set selected parameter
--    (left column == track 1)
--
-- grid controls:
--  top row (left to right):
--    track 1, track 2
--    notes, divs, octaves
--    settings
--
--  settings page:
--    row 2&3:
--     single press 'jump to' 
--     double press sets loop 
--    row 4&5 = track rates
--    row 6&7 = trigger lengths
--
--
-- quirks!:
-- No note selected will pause 
-- for the length of time division 
-- (as set per divs)
-- No div' selected defaults to a 
-- normal step rest
-- No octave selected defaults 0
-- Crow drops occasional messages





notes1 = {}
notes2 = {}
divs1 = {}
divs2 = {}
octaves1 = {}
octaves2 = {}


g = grid.connect()

function init()
  for i=1,16 do
      notes1[i] = {}
      notes2[i] = {}-- create a new col
      divs1[i] = {}
      divs2[i] = {}
      octaves1[i] = {}
      octaves2[i] = {}
    for j=2,8 do
        notes1[i][j] = 0
        notes2[i][j] = 0
        divs1[i][j] = 0
        divs2[i][j] = 0
        octaves1[i][j] = 0
        octaves2[i][j] = 0
      for k=1,16 do
          notes1[i][2] = 1
          notes2[i][2] = 1
          divs1[i][2] = 1
          divs2[i][2] = 1
          octaves1[i][2] = 1
          octaves2[i][2] = 1
      end
    end
  end
  lane1 = clock.run(first)
  lane2 = clock.run(second)
  clock.cancel(lane1)
  clock.cancel(lane2)
  grid_redraw()
end


page = 1
subpage = 6

volts1 = 0
slew1 = 0.01
setpulse1 = .005
pulseindex1 = 1
pulse1 = "pulse("..setpulse1..",5,1)"

--pulse1 = "pulse(.005,5,1)"

volts2 = 0
slew2 = 0.01
setpulse2 = .005
pulseindex2 = 1
pulse2 = "pulse("..setpulse2..",5,1)"

i1 = 0
i2 = 0
io1 = 1
io2 = 1
go = 0
length1 = 16
length2 = 16
offset1 = 1
offset2 = 1
check1 = {}
check2 = {}
loop1min = 1
loop1max = 16
loop2min = 1
loop2max = 16
keycount1 = 0
keycount2 = 0
live1 = 1
live2 = 1
lednotes1 = 0
leddivs1 = 0
ledoctaves1 = 0
lednotes2 = 0
leddivs2 = 0
ledoctaves2 = 0

usemedivs1 = 1
usemenotes1 = 1
usemeoctaves1 = 1
usemedivs2 = 1
usemenotes2 = 1
usemeoctaves2 = 1

tempdivs1 = {}
tempnotes1 = {}
tempoctaves1 = {}

tempdivs2 = {}
tempnotes2 = {}
tempoctaves2 = {}

masterrate1 = 1
masterrate2 = 1
rateindex1 = 4
rateindex2 = 4

globalrates = {4,3,2,1,0.5,0.3333,0.25,0.125,1,1.1,1.2,1.3,1.4,1.5,1.6,1.7}


ic =  1
enc2 = 1
enc3 = 1 


a = {15,1,1,1,1,1,1,1,1,1,1,1,1,1} -- highlted norns menu table

divslist = {1,2,3,4,5,6,7,8} 
convert = {1,0.5,0.333333333,0.25,0.2,0.1667,0.1428,0.125} --whole,half,triplet,quarter note etc upto eightnotes

noteslist = {"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"} --list to display to users?
pitch = {0,1,2,3,4,5,6,7,8,9,10,11} -- hard coded, dont change

octaveslist = {0,1,2,3,4,5,6,7} 

selectednotes1 = {0,4,5,7,9,11,11} 
selecteddivs1 = {1,2,3,4,6,7,8} --these tables can only be 7 long
selectedoctaves1 = {0,1,2,3,4,5,6} 

selectednotes2 = {0,4,5,7,9,11,11} 
selecteddivs2 = {1,2,3,4,6,7,8} --these tables can only be 7 long
selectedoctaves2 = {0,1,2,3,4,5,6} 

pulses = {.005,.010,.020,.030,.040,.050,.060,.070,.080,.090,.1,.15,.2,.25,.3,.4}




function first()
  while go==1 do
    i1 = (i1 % length1) + 1
    io1 = i1 + (offset1 - 1)
    --print(i1.."     i1")
    --print(io1.."    iol")
    for c = 2,8 do
      if divs1[io1][c]==1 then
        table.insert(tempdivs1,c)
      end --NEED
    end --NEED
    if #tempdivs1 > 0 then  --just added
        qdiv1 = math.random (1,#tempdivs1) --generate a random number, based on the table length
        live1 = 1
        usemedivs1 = selecteddivs1[(tempdivs1[qdiv1] - 1)] 
        leddivs1 = tempdivs1[qdiv1]
        for w = 1,#tempdivs1 do  
          tempdivs1[w] = nil    
        end 
      else
       qdiv1 = 1 
        live1 = 0 
        usemedivs1 = 1
    end
    for d = 1,usemedivs1 do
      --if live1 == 1 then
  -----------------SET NOTE/PITCH      
    for c = 2,8 do 
      if notes1[io1][c]==1 then 
        table.insert(tempnotes1,c) -- which stpes on table had a 1 in them 
      end --NEED
    end --NEED
    if #tempnotes1 > 0 then  --just added
        qnote1 = math.random (1,#tempnotes1) --generate a random number, based on the table length
        live1 = 1
        usemenotes1 = selectednotes1[(tempnotes1[qnote1] - 1)]
        lednotes1 = tempnotes1[qnote1]
        for w = 1,#tempnotes1 do  --- wipes temp table to be repopulated on next pass
          tempnotes1[w] = nil  
        end 
      else
        qnote1 = 1 
        live1 = 0 
        usemenotes1 = 1
        lednotes1 = 2
    end
    ------------ SET OCTAVE 
    for c = 2,8 do 
      if octaves1[io1][c]==1 then 
        table.insert(tempoctaves1,c) -- which stpes on table had a 1 in them 
      end --NEED
    end --NEED
    if #tempoctaves1 > 0 then  --just added
        qoctave1 = math.random (1,#tempoctaves1) --generate a random number, based on the table length
        usemeoctaves1 = selectedoctaves1[(tempoctaves1[qoctave1] - 1)]
        ledoctaves1 = tempoctaves1[qoctave1]
        for w = 1,#tempoctaves1 do  --- wipes temp table to be repopulated on next pass
          tempoctaves1[w] = nil    
        end 
      else
        qoctave1 = 0
        live1 = 0 
        usemeoctaves1 = 0
    end
 ------------------ 
      if live1 == 1 then
        if usemedivs1~=1 then
          volts1 = (0.08333333 * usemenotes1) + (1 * usemeoctaves1)
          crow.output[1].volts = volts1
          crow.output[1].slew = slew1
          crow.output[2].action = pulse1
          crow.output[2].execute()
          --redraw(i1)
          grid_redraw()
          co = usemedivs1
          clock.sync((convert[co] * masterrate1))
          else
          volts1 = (0.08333333 * usemenotes1) + (1 * usemeoctaves1)
          crow.output[1].volts = volts1
          crow.output[1].slew = slew1
          crow.output[2].action = pulse1
          crow.output[2].execute()
          --redraw(i1)
          grid_redraw()
          clock.sync(masterrate1)
        end
      else
        print("nope")
        clock.sync(masterrate1)
      end 
    end
  end    
end

function second()
  while go==1 do
    i2 = (i2 % length2) + 1
    io2 = i2 + (offset2 - 1)
    for c = 2,8 do
      if divs2[io2][c]==1 then 
        table.insert(tempdivs2,c) 
      end 
    end 
    if #tempdivs2 > 0 then
        qdiv2 = math.random (1,#tempdivs2) --generate a random number, based on the table length
        live2 = 1
        usemedivs2 = selecteddivs2[(tempdivs2[qdiv2] - 1)] 
        leddivs2 = tempdivs2[qdiv2]
        for w = 1,#tempdivs2 do  
          tempdivs2[w] = nil  
        end 
      else
       qdiv2 = 1
        live2 = 0
        usemedivs2 = 1
    end
    for d = 1,usemedivs2 do

  -----------------SET NOTE/PITCH      
    for c = 2,8 do 
      if notes2[io2][c]==1 then
        table.insert(tempnotes2,c)
      end --NEED
    end --NEED
    if #tempnotes2 > 0 then  --just added
        qnote2 = math.random (1,#tempnotes2) --generate a random number, based on the table length
        live2 = 1
        usemenotes2 = selectednotes2[(tempnotes2[qnote2] - 1)]
        lednotes2 = tempnotes2[qnote2]
        for w = 1,#tempnotes2 do
          tempnotes2[w] = nil
        end 
      else
        qnote2 = 1
        live2 = 0
        usemenotes2 = 1
        lednotes2 = 2
    end
    ------------ SET OCTAVE 
    for c = 2,8 do
      if octaves2[io2][c]==1 then
        table.insert(tempoctaves2,c) -- which stpes on table had a 1 in them 
      end
    end 
    if #tempoctaves2 > 0 then  --just added
        qoctave2 = math.random (1,#tempoctaves2)
        usemeoctaves2 = selectedoctaves2[(tempoctaves2[qoctave2] - 1)]
        ledoctaves2 = tempoctaves2[qoctave2]
        for w = 1,#tempoctaves2 do  --wipes temp table to be repopulated on next pass
          tempoctaves2[w] = nil    
        end 
      else
        qoctave2 = 0
        live2 = 0
        usemeoctaves2 = 0
    end
 ------------------ 
      if live2 == 1 then
        if usemedivs2~=1 then
          volts2 = (0.08333333 * usemenotes2) + (1 * usemeoctaves2)
          crow.output[3].volts = volts2
          crow.output[3].slew = slew2
          crow.output[4].action = pulse2
          crow.output[4].execute()
          --redraw(i2)
          grid_redraw()
          co = usemedivs2
          clock.sync((convert[co] * masterrate2))
          else
          volts2 = (0.08333333 * usemenotes2) + (1 * usemeoctaves2)
          crow.output[3].volts = volts2
          crow.output[3].slew = slew2
          crow.output[4].action = pulse2
          crow.output[4].execute()
          --redraw(i2)
          grid_redraw()
          clock.sync(masterrate2)
        end
      else
        print("nope")
        clock.sync(masterrate2)
      end 
    end
  end    
end




function key(n,z)
  if z == 1 then
    if n == 3 then
      npagecount(1)
      if ic == 1 and page == 1 then enc3 = (selectednotes1[enc2] + 1) end
      if ic == 1 and page == 2 then enc3 = (selectednotes2[enc2] + 1) end
      if ic == 2 and page == 1 then enc3 = (selecteddivs1[enc2]) end
      if ic == 2 and page == 2 then enc3 = (selecteddivs2[enc2]) end
      if ic == 3 and page == 1 then enc3 = (selectedoctaves1[enc2] + 1) end
      if ic == 3 and page == 2 then enc3 = (selectedoctaves2[enc2] + 1) end
    elseif n == 2 then
      npagecount(- 1)
      if ic == 1 and page == 1 then enc3 = (selectednotes1[enc2] + 1) end
      if ic == 1 and page == 2 then enc3 = (selectednotes2[enc2] + 1) end
      if ic == 2 and page == 1 then enc3 = (selecteddivs1[enc2]) end
      if ic == 2 and page == 2 then enc3 = (selecteddivs2[enc2]) end
      if ic == 3 and page == 1 then enc3 = (selectedoctaves1[enc2] + 1) end
      if ic == 3 and page == 2 then enc3 = (selectedoctaves2[enc2] + 1) end
    end
  end
end

function enc(n,d)
  if d > 0 then
    dinc = 1
  elseif d < 0 then
      dinc = -1
  end
  if ic == 1 then
    if n == 3 then
      enc3 = enc3 + dinc
      check = enc3
      if check > 12 then
        enc3 = 1
      elseif check < 1 then
        enc3 = 12
      else
      end
      if enc2 >=8 then
        selectednotes2[enc2 - 7] = pitch[enc3]
        redraw()
      elseif enc2 <=7 then
        selectednotes1[enc2] = pitch[enc3]
        redraw()
      end
    elseif n == 2 then
      enc2 = enc2 + dinc
      check = enc2
      if check > 14 then
        enc2 = 1
      elseif check < 1 then
        enc2 = 14
      else
      end
      if enc2 >=8 then
        enc3 = (selectednotes2[enc2 - 7]) + 1
        redraw()
      elseif enc2 <=7 then
        enc3 = (selectednotes1[enc2]) + 1
        redraw()
      end
      for highlighted = 1,14 do
          a[highlighted] = 1
      end
      a[enc2] = 15
      redraw()
    end
    
  elseif ic == 2 then
    if n == 3 then
      enc3 = enc3 + dinc
      check = enc3
      if check > 8 then
        enc3 = 1
      elseif check < 1 then
        enc3 = 8
      else
      end
      if enc2 >=8 then
        selecteddivs2[enc2 - 7] = divslist[enc3]
        redraw()
      elseif enc2 <=7 then
        selecteddivs1[enc2] = divslist[enc3]
        redraw()
      end
    elseif n == 2 then
      enc2 = enc2 + dinc
      check = enc2
      if check > 14 then
        enc2 = 1
      elseif check < 1 then
        enc2 = 14
      else
      end
      if enc2 >=8 then
        enc3 = (selecteddivs2[enc2 - 7]) 
        redraw()
      elseif enc2 <=7 then
        enc3 = (selecteddivs1[enc2]) 
        redraw()
      end
      for highlighted = 1,14 do
          a[highlighted] = 1
      end
      a[enc2] = 15
      redraw()
    end   
  
  elseif ic == 3 then
    if n == 3 then
      enc3 = enc3 + dinc
      check = enc3
      if check > 8 then
        enc3 = 1
      elseif check < 1 then
        enc3 = 8
      else
      end
      if enc2 >=8 then
        selectedoctaves2[enc2 - 7] = octaveslist[enc3]
        redraw()
      elseif enc2 <=7 then
        selectedoctaves1[enc2] = octaveslist[enc3]
        redraw()
      end
    elseif n == 2 then
      enc2 = enc2 + dinc
      check = enc2
      if check > 14 then
        enc2 = 1
      elseif check < 1 then
        enc2 = 14
      else
      end
      if enc2 >=8 then
        enc3 = (selectedoctaves2[enc2 - 7]) + 1
        redraw()
      elseif enc2 <=7 then
        enc3 = (selectedoctaves1[enc2]) + 1
        redraw()
      end
      for highlighted = 1,14 do
          a[highlighted] = 1
      end
      a[enc2] = 15
      redraw()
    end  
   end
  
  if ic == 4 then 
    if n == 3 and dinc > 0 and go == 0 then
      if go == 0 then -- extra check to make double space play head happen less
          go = 1 -- must happen before clock run!
      end
      clock.run(first) 
      clock.run(second) 
      print("playing")
      redraw()
    elseif n ==3 and dinc < 0 and go == 1 then
            go = 0
   -- --  first(i1) -- no idea what do 
   --  -- second(i2) -- no idea what do 
   clock.cancel(lane1) 
   clock.cancel(lane2) 
      i1 = 0
      i2 = 0 --- these bits might need to be resequenced
      io1 = 1 -- 
      io2 = 1 
      redraw()
    end
  end
end 


function npagecount(move)
  if move == 1 then
    if ic >= 4 then
      ic = 1
    else  
      ic = ic + 1
    end
  elseif move == -1 then
    if ic <= 1 then
      ic = 4
    else  
      ic = ic - 1
    end
  end
  print(ic)
  redraw()
end


function redraw()
  gm = 9
  hm = 39
  im = 61
  jm = 100
  gl = 15
  hl = 1
  il = 1
  jl = 1
  textdown = 7
  
  if ic == 1 then
    gl = 15;  hl = 2;   il = 2;   jl = 2
  elseif ic == 2 then
    gl = 2;   hl = 15;  il = 2;   jl = 2
  elseif ic == 3 then
    gl = 2;   hl = 2;   il = 15;  jl = 2
  elseif ic == 4 then
    gl = 2;   hl = 2;   il = 2;   jl = 15
  end
        


  screen.clear()
  screen.move(gm,textdown)----------------
  screen.level(gl)
  screen.text("notes")
  screen.move(hm,textdown)
  screen.level(hl)------------This bit draws the top menu bar
  screen.text("divs")
  screen.move(im,textdown)
  screen.level(il)
  screen.text("octaves")
  screen.move(jm,textdown)
  screen.level(jl)
  screen.text("play")--------------------
  
  
  if ic == 1 then
    e = 30
    f = 80
    screen.move(e,14)
    screen.level(a[1])
    screen.text(noteslist[(selectednotes1[1] + 1)])
      screen.move(e,22)
    screen.level(a[2])
    screen.text(noteslist[(selectednotes1[2] + 1)])
        screen.move(e,30)
    screen.level(a[3])
    screen.text(noteslist[(selectednotes1[3] + 1)])
        screen.move(e,38)
    screen.level(a[4])
    screen.text(noteslist[(selectednotes1[4] + 1)])
        screen.move(e,46)
    screen.level(a[5])
    screen.text(noteslist[(selectednotes1[5] + 1)])
          screen.move(e,54)
    screen.level(a[6])
    screen.text(noteslist[(selectednotes1[6] + 1)])
          screen.move(e,62)
    screen.level(a[7])
    screen.text(noteslist[(selectednotes1[7] + 1)])
    
    
      screen.move(f,14)
    screen.level(a[8])
    screen.text(noteslist[(selectednotes2[1] + 1)])
      screen.move(f,22)
    screen.level(a[9])
    screen.text(noteslist[(selectednotes2[2] + 1)])
        screen.move(f,30)
    screen.level(a[10])
    screen.text(noteslist[(selectednotes2[3] + 1)])
        screen.move(f,38)
    screen.level(a[11])
    screen.text(noteslist[(selectednotes2[4] + 1)])
        screen.move(f,46)
    screen.level(a[12])
    screen.text(noteslist[(selectednotes2[5] + 1)])
          screen.move(f,54)
    screen.level(a[13])
    screen.text(noteslist[(selectednotes2[6] + 1)])
          screen.move(f,62)
    screen.level(a[14])
    screen.text(noteslist[(selectednotes2[7] + 1)])
    screen.update()
    
    
  elseif ic == 2 then
    e = 30
    f = 80
    screen.move(e,14)
    screen.level(a[1])
    screen.text(divslist[(selecteddivs1[1])])
      screen.move(e,22)
    screen.level(a[2])
    screen.text(divslist[(selecteddivs1[2])])
        screen.move(e,30)
    screen.level(a[3])
    screen.text(divslist[(selecteddivs1[3])])
        screen.move(e,38)
    screen.level(a[4])
    screen.text(divslist[(selecteddivs1[4])])
        screen.move(e,46)
    screen.level(a[5])
    screen.text(divslist[(selecteddivs1[5])])
          screen.move(e,54)
    screen.level(a[6])
    screen.text(divslist[(selecteddivs1[6])])
          screen.move(e,62)
    screen.level(a[7])
    screen.text(divslist[(selecteddivs1[7])])
    
    
      screen.move(f,14)
    screen.level(a[8])
    screen.text(divslist[(selecteddivs2[1])])
      screen.move(f,22)
    screen.level(a[9])
    screen.text(divslist[(selecteddivs2[2])])
        screen.move(f,30)
    screen.level(a[10])
    screen.text(divslist[(selecteddivs2[3])])
        screen.move(f,38)
    screen.level(a[11])
    screen.text(divslist[(selecteddivs2[4])])
        screen.move(f,46)
    screen.level(a[12])
    screen.text(divslist[(selecteddivs2[5])])
          screen.move(f,54)
    screen.level(a[13])
    screen.text(divslist[(selecteddivs2[6])])
          screen.move(f,62)
    screen.level(a[14])
    screen.text(divslist[(selecteddivs2[7])])
    screen.update()

  elseif ic == 3 then
    e = 30
    f = 80
    screen.move(e,14)
    screen.level(a[1])
    screen.text(octaveslist[(selectedoctaves1[1] + 1)])
      screen.move(e,22)
    screen.level(a[2])
    screen.text(octaveslist[(selectedoctaves1[2] + 1)])
        screen.move(e,30)
    screen.level(a[3])
    screen.text(octaveslist[(selectedoctaves1[3] + 1)])
        screen.move(e,38)
    screen.level(a[4])
    screen.text(octaveslist[(selectedoctaves1[4] + 1)])
        screen.move(e,46)
    screen.level(a[5])
    screen.text(octaveslist[(selectedoctaves1[5] + 1)])
          screen.move(e,54)
    screen.level(a[6])
    screen.text(octaveslist[(selectedoctaves1[6] + 1)])
          screen.move(e,62)
    screen.level(a[7])
    screen.text(octaveslist[(selectedoctaves1[7] + 1)])
    
    
      screen.move(f,14)
    screen.level(a[8])
    screen.text(octaveslist[(selectedoctaves2[1] + 1)])
      screen.move(f,22)
    screen.level(a[9])
    screen.text(octaveslist[(selectedoctaves2[2] + 1)])
        screen.move(f,30)
    screen.level(a[10])
    screen.text(octaveslist[(selectedoctaves2[3] + 1)])
        screen.move(f,38)
    screen.level(a[11])
    screen.text(octaveslist[(selectedoctaves2[4] + 1)])
        screen.move(f,46)
    screen.level(a[12])
    screen.text(octaveslist[(selectedoctaves2[5] + 1)])
          screen.move(f,54)
    screen.level(a[13])
    screen.text(octaveslist[(selectedoctaves2[6] + 1)])
          screen.move(f,62)
    screen.level(a[14])
    screen.text(octaveslist[(selectedoctaves2[7] + 1)])
    screen.update()
  elseif ic == 4 then
    if go == 0 then  
      screen.move(22,32)
      screen.level(15)
      screen.font_size(8)
      screen.text("stopped")
      screen.move(62,32)
      screen.level(1)
      screen.font_size(8)
      screen.text("playing")
    elseif go == 1 then
      screen.move(22,32)
      screen.level(1)
      screen.font_size(8)
      screen.text("stopped")
      screen.move(62,32)
      screen.level(15)
      screen.font_size(8)
      screen.text("playing") 
    end
    screen.update()
  end
end

--------------- grid stuff below


g.key = function(x,y,z)
  if y == 1 and x == 2 then
      page = 2
      grid_redraw()
    elseif y == 1 and x == 1 then
      page = 1
      grid_redraw()
  end
  if y == 1 and x == 6 then
      subpage = 6
      grid_redraw()
    elseif y == 1 and x == 7 then
      subpage = 7
      grid_redraw()
    elseif y == 1 and x == 8 then
      subpage = 8
      grid_redraw()
    elseif z == 1 and y == 1 and x == 16 then
      subpage = 16
      grid_redraw()
  end
 
  
  if page == 1 and subpage == 6 then
    if z == 1 and y ~= 1 and notes1[x][y] == 0 then
        notes1[x][y] = 1
        grid_redraw()
      elseif z == 1 and notes1[x][y] == 1 then
        notes1[x][y] = 0
        grid_redraw()
    end
  elseif page == 2  and subpage == 6 then
    if z == 1 and y ~= 1 and notes2[x][y] == 0 then
        notes2[x][y] = 1
        grid_redraw()
      elseif z == 1 and notes2[x][y] == 1 then
        notes2[x][y] = 0
        grid_redraw()
    end
  end
  if page == 1 and subpage == 7 then
      if z == 1 and y ~= 1 and divs1[x][y] == 0 then
        divs1[x][y] = 1
        grid_redraw()
      elseif z == 1 and divs1[x][y] == 1 then
        divs1[x][y] = 0
        grid_redraw()
      end
  elseif page == 2  and subpage == 7 then
      if z == 1 and y ~= 1 and divs2[x][y] == 0 then
        divs2[x][y] = 1
        grid_redraw()
      elseif z == 1 and divs2[x][y] == 1 then
        divs2[x][y] = 0
        grid_redraw()
      end
  end
  if page == 1 and subpage == 8 then
      if z == 1 and y ~= 1 and octaves1[x][y] == 0 then
        octaves1[x][y] = 1
        grid_redraw()
      elseif z == 1 and octaves1[x][y] == 1 then
        octaves1[x][y] = 0
        grid_redraw()
      end
  elseif page == 2  and subpage == 8 then
      if z == 1 and y ~= 1 and octaves2[x][y] == 0 then
        octaves2[x][y] = 1
        grid_redraw()
      elseif z == 1 and octaves2[x][y] == 1 then
        octaves2[x][y] = 0
        grid_redraw()
      end
  end
if (page == 1 or page == 2) and subpage == 16 then
  if y == 2 then
    if keycount1 == 1 then
      check1[2] = x
      keycount1 = 0
    elseif keycount1 == 0 and z == 1 then
      check1[1] = x
      keycount1 = 1
    end
  end
  
  if check1[1] ~= nil and check1[2] ~= nil then
    if check1[1] == check1[2] then
      i1 = (check1[1] - offset1)
      for wipe1 = 1,#check1 do
        check1[wipe1] = nil
      end 
      grid_redraw()
    elseif check1[1] ~= check1[2] then
      if check1[1] < check1[2] then
        loop1min = check1[1]
        loop1max = check1[2]
        length1 = (loop1max - loop1min) + 1
        offset1 = loop1min
        grid_redraw()
        for wipe1 = 1,#check1 do
          check1[wipe1] = nil
        end 
      elseif check1[1] > check1[2] then
        loop1min = check1[2]
        loop1max = check1[1]
        length1 = (loop1max - loop1min) + 1
        offset1 = loop1min
        grid_redraw()
        for wipe1 = 1,#check1 do
          check1[wipe1] = nil
        end 
      end
    end
  end
  
  if y == 3 then
    if keycount2 == 1 then
      check2[2] = x
      keycount2 = 0
    elseif keycount2 == 0 and z == 1 then
      check2[1] = x
      keycount2 = 1
    end
  end
  
  if check2[1] ~= nil and check2[2] ~= nil then
    if check2[1] == check2[2] then
      i2 = (check2[1] - offset2)
      for wipe2 = 1,#check2 do
        check2[wipe2] = nil
      end 
      grid_redraw()
    elseif check2[1] ~= check2[2] then
      if check2[1] < check2[2] then
        loop2min = check2[1]
        loop2max = check2[2]
        length2 = (loop2max - loop2min) + 1
        offset2 = loop2min
        grid_redraw()
        for wipe2 = 1,#check2 do
          check2[wipe2] = nil
        end 
      elseif check2[1] > check2[2] then
        loop2min = check2[2]
        loop2max = check2[1]
        length2 = (loop2max - loop2min) + 1
        offset2 = loop2min
        grid_redraw()
        for wipe2 = 1,#check2 do
          check2[wipe2] = nil
        end 
      end
    end
  end
  
  if y == 4 and z == 1 then 
      masterrate1 = globalrates[x]
      rateindex1 = x
      grid_redraw()
  end
  
  if y == 5 and z == 1 then 
      masterrate2 = globalrates[x]
      rateindex2 = x
      grid_redraw()
  end
  
  if y == 6 and z == 1 then 
    setpulse1 = (pulses[x])
    pulseindex1 = x
    pulse1 = "pulse("..setpulse1..",5,1)"
    grid_redraw()
  end
  
  if y == 7 and z == 1 then 
    setpulse2 = (pulses[x])
    pulseindex2 = x
    pulse2 = "pulse("..setpulse2..",5,1)"
    grid_redraw()
  end
  
end
end


function grid_redraw()
  g:all(0)
    if page == 1 and subpage == 6 then
      for i=1,16 do
        for j=2,8 do
          if notes1[i][j]==1 then
            z=1
            g:led(i,j,z*8)
          g:led(io1,lednotes1,15)
          end
        end
      end
    end
    if page == 2 and subpage == 6 then
      for i=1,16 do
        for j=2,8 do
          if notes2[i][j]==1 then
            z=1
            g:led(i,j,z*8)
            g:led(io2,lednotes2,15)
          end
        end
      end
    end
    
      if page == 1 and subpage == 7 then
      for i=1,16 do
        for j=2,8 do
          if divs1[i][j]==1 then
            z=1
            g:led(i,j,z*8)
            g:led(io1,leddivs1,15)
          end
        end
      end
    end
    if page == 2 and subpage == 7 then
      for i=1,16 do
        for j=2,8 do
          if divs2[i][j]==1 then
            z=1
            g:led(i,j,z*8)
            g:led(io2,leddivs2,15)
          end
        end
      end
    end
    
    if page == 1 and subpage == 8 then
      for i=1,16 do
        for j=2,8 do
          if octaves1[i][j]==1 then
            z=1
            g:led(i,j,z*8)
            g:led(io1,ledoctaves1,15)
          end
        end
      end
    end
    if page == 2 and subpage == 8 then
      for i=1,16 do
        for j=2,8 do
          if octaves2[i][j]==1 then
            z=1
            g:led(i,j,z*8)
            g:led(io2,ledoctaves2,15)
          end
        end
      end
    end
    if subpage == 16 then
      for lp1=loop1min,loop1max do
          z=1
          g:led(lp1,2,z*5)
          g:led(io1,2,15)
      end
      for lp2=loop2min,loop2max do
          z=1
          g:led(lp2,3,z*5)
          g:led(io2,3,15)
      end
      g:led(rateindex1,4,10)
      g:led(rateindex2,5,10)
      for p1 = 1,pulseindex1 do
        g:led(p1,6,5)
        g:led(pulseindex1,6,7)
      end
      for p2 = 1,pulseindex2 do
        g:led(p2,7,5)
        g:led(pulseindex2,7,7)
      end
    end
  for k =1,2 do
    g:led(k,1,5)
  end
  for l = 6,8 do
    g:led(l,1,5)
  end
    g:led(16,1,5)
    if subpage == 16 then g:led(1,1,15);g:led(2,1,15)
      else g:led((page),1,15)
    end  
    g:led((subpage),1,15)  
    g:refresh()
end


function totalclear()
  screen.clear()
  screen.update()
end
