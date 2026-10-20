// Original StatOz discovery artwork. Author at Flutter's 220 x 160 master size.
import fs from 'node:fs';
import path from 'node:path';
export const materials = {
  ink:'#081019', panel:'#1D293D', edge:'#45556C', slate:'#314158', pale:'#EAF0F7',
  shadow:'#0B1322', turf:'#185448', turfLight:'#246B5B', turfDeep:'#10392F',
  clay:'#9C7950', clayLight:'#C8AA77', clayDeep:'#61472E', wood:'#B47743',
  woodLight:'#DDA169', woodDeep:'#6E472D', orange:'#FF8904', orangeDeep:'#AE471D',
  red:'#EA565A', redDeep:'#962B3C', lime:'#D4E887', court:'#245063',
  courtLight:'#397287', courtDeep:'#183746', rubber:'#111B28', steel:'#A6B8CD',
  skin:'#C59070', skinLight:'#E3B494', skinDeep:'#92654F', hair:'#293543', gold:'#FDC700',
};
export const catalog = [
  ['pitch-duel','pitchDuel','football','PITCH DUEL','tactics','#5CDFFF'],
  ['penalty-shootout','penaltyShootout','football','PENALTY SHOOTOUT','penalty','#FFA08C'],
  ['football-quiz','footballQuiz','football','FOOTBALL QUIZ','quiz','#C27AFF'],
  ['guess-player','footballGuessPlayer','football','GUESS THE PLAYER','player','#FF94C1'],
  ['football-bingo','footballBingo','football','FOOTBALL BINGO','bingo','#FFB968'],
  ['football-chess','footballChess','football','5V5 FOOTBALL CHESS','chess','#8EC5FF'],
  ['final-over','finalOver','cricket','FINAL OVER','cricket','#E3E3E3'],
  ['cricket-quiz','cricketQuiz','cricket','CRICKET QUIZ','quiz','#9CE8C3'],
  ['cricket-guess-player','cricketGuessPlayer','cricket','GUESS THE PLAYER','player','#53D9BA'],
  ['hoop-duel','hoopDuel','basketball','HOOP DUEL','basketball','#FDC700'],
  ['basketball-quiz','basketballQuiz','basketball','BASKETBALL QUIZ','quiz','#FFC08C'],
  ['basketball-guess-player','basketballGuessPlayer','basketball','GUESS THE PLAYER','player','#E5A4EA'],
  ['grand-prix-dash','grandPrixDash','motorsport','GRAND PRIX DASH','racing','#FF777D'],
  ['motorsport-quiz','motorsportQuiz','motorsport','MOTORSPORT QUIZ','quiz','#F58ACA'],
  ['guess-driver','guessDriver','motorsport','GUESS THE DRIVER','driver','#AFA9FF'],
  ['tennis-rally','tennisRally','tennis','TENNIS RALLY','tennis','#51FF94'],
  ['tennis-quiz','tennisQuiz','tennis','TENNIS QUIZ','quiz','#D4E887'],
  ['tennis-guess-winner','guessWinner','tennis','GUESS THE WINNER','winner','#7CEAE5'],
];
const c = key => materials[key] ?? key;
const p=(d,fill,stroke='none',w=1.2)=>`<path d="${d}" fill="${c(fill)}" stroke="${c(stroke)}" stroke-width="${w}" stroke-linejoin="round"/>`;
const poly=(pts,fill,stroke='none',w=1.2)=>`<polygon points="${pts}" fill="${c(fill)}" stroke="${c(stroke)}" stroke-width="${w}" stroke-linejoin="round"/>`;
const circle=(x,y,r,fill,stroke='none',w=1.2)=>`<circle cx="${x}" cy="${y}" r="${r}" fill="${c(fill)}" stroke="${c(stroke)}" stroke-width="${w}"/>`;
const ellipse=(x,y,rx,ry,fill,opacity=1)=>`<ellipse cx="${x}" cy="${y}" rx="${rx}" ry="${ry}" fill="${c(fill)}" opacity="${opacity}"/>`;
const line=(d,color='pale',w=1.2,opacity=1)=>`<path d="${d}" fill="none" stroke="${c(color)}" stroke-width="${w}" opacity="${opacity}" stroke-linecap="round" stroke-linejoin="round"/>`;
const group=(body,transform)=>`<g transform="${transform}">${body}</g>`;
const cut=(x,y,w,h,n=6)=>`M${x+n} ${y}H${x+w}V${y+h-n}L${x+w-n} ${y+h}H${x}V${y+n}Z`;
function ball(sport,x,y,r){
  if(sport==='football') return circle(x,y,r,'pale','steel')+p(`M${x} ${y-r*.42}l${r*.42} ${r*.31}-${r*.16} ${r*.48}h-${r*.52}l-${r*.16}-${r*.48}Z`,'ink')+line(`M${x} ${y-r*.42}v-${r*.54}m${r*.42} ${r*.85} ${r*.51}-${r*.15}m-${r*.68} ${r*.64} ${r*.31} ${r*.5}m-${r*.83}-${r*.5}-${r*.31} ${r*.5}m${r*.15}-${r*.98}-${r*.5}-${r*.15}`,'ink',1)+p(`M${x+r*.1} ${y-r*.95}A${r} ${r} 0 0 1 ${x+r*.66} ${y+r*.74}Q${x+r*.5} ${y} ${x+r*.1} ${y-r*.95}`,'steel');
  if(sport==='basketball') return circle(x,y,r,'orange','orangeDeep',1.5)+p(`M${x+r*.12} ${y-r*.96}A${r} ${r} 0 0 1 ${x+r*.62} ${y+r*.78}Q${x+r*.4} ${y} ${x+r*.12} ${y-r*.96}`,'orangeDeep')+line(`M${x-r} ${y}H${x+r}M${x} ${y-r}V${y+r}M${x-r*.7} ${y-r*.7}Q${x+r*.3} ${y} ${x-r*.7} ${y+r*.7}M${x+r*.7} ${y-r*.7}Q${x-r*.3} ${y} ${x+r*.7} ${y+r*.7}`,'ink',1.2);
  if(sport==='cricket')return circle(x,y,r,'red','redDeep')+p(`M${x+r*.1} ${y-r*.96}A${r} ${r} 0 0 1 ${x+r*.65} ${y+r*.76}Q${x+r*.25} ${y} ${x+r*.1} ${y-r*.96}`,'redDeep')+line(`M${x-r*.3} ${y-r*.92}Q${x+r*.2} ${y} ${x-r*.3} ${y+r*.92}`,'pale',1.5);
  return circle(x,y,r,'lime','turfDeep')+line(`M${x-r*.64} ${y-r*.76}Q${x+r*.45} ${y} ${x-r*.64} ${y+r*.76}`,'pale',1.4);
}
function racket(x,y,s=1,accent='steel'){return group(ellipse(0,0,13,19,'courtDeep')+`<ellipse cx="0" cy="0" rx="13" ry="19" fill="none" stroke="${c(accent)}" stroke-width="3"/>`+line('M-9-12H9M-12-6H12M-12 0H12M-12 6H12M-9 12H9M-6-16V16M0-18V18M6-16V16','pale',.7,.6)+p('M-7 17 0 29 7 17 3 19 0 24-3 19Z','steel')+p('M-2 27H2V46H-2Z','clayDeep','steel',.7)+line('M-2 32H2M-2 36H2M-2 40H2','pale',.7,.5),`translate(${x} ${y}) rotate(-28) scale(${s})`);}
function bat(x,y,s=1){return group(p('M-3-35H3V-15L8-10V34L5 38H-7L-8 34V-10L-3-15Z','clayLight','clayDeep')+p('M2-11H8V34L5 38H2Z','clay')+p('M-3-35H3V-16H-3Z','ink')+line('M-3-31H3M-3-26H3M-3-21H3','steel',1)+p('M-6-7H-3V27H-6Z','pale'),`translate(${x} ${y}) rotate(25) scale(${s})`);}
function helmet(x,y,s=1,a){return group(p('M-27 12V-5L-20-24-6-31 15-27 29-12 32 9 18 27H-13Z',a,'ink',2)+p('M5-29 21-22 30-8 32 9 18 27H4L12 8Z','panel')+p('M-23-5 25-7 30 4 9 15-18 9Z','ink','steel',1.5)+p('M-17-1 19-3 23 1-12 4Z','courtLight')+line('M-16-19-7-24H7','pale',2,.7)+p('M-16 16 11 20 16 26H-11Z','steel'),`translate(${x} ${y}) scale(${s})`);}
function portrait(sport,a,variant=0){
  const face=poly('94,40 105,31 125,34 135,46 132,67 118,78 103,71 95,55','skin')+poly('122,36 135,46 132,67 118,78 118,58','skinDeep')+poly('101,39 109,34 118,36 111,56 100,52','skinLight')+p('M94 43 93 32 104 22 127 26 138 37 134 50 123 39 104 41 98 48Z','hair')+line('M104 55H110M122 54H128','ink',1.4)+line('M113 66H120','skinDeep',1.4);
  const torso=p(sport==='basketball'?'M101 82 113 89 126 82 142 98 141 126H83L83 99Z':'M100 80 112 89 127 80 152 95 142 112 135 107 138 128H84L87 108 80 113 69 96Z',a,'ink',1.7)+p('M114 89 126 82 141 97 138 128H117Z','panel')+line('M101 83 112 93 126 84','pale',1.5,.75);
  return torso+face+(sport==='cricket'?p('M91 34 100 22 122 23 138 33 137 40 91 40Z',a)+p('M90 39H144L149 45H103Z','panel'):sport==='basketball'?p('M94 38 133 39 135 45 95 44Z','pale'):'')+(variant?line('M88 112H98M88 118H106',a,1.5):'');
}
function tileCard(x,y,w,h,a,body=''){return p(cut(x,y,w,h), 'panel',a,1.5)+p(cut(x+3,y+3,w-6,h-6,4),'shadow')+body+poly(`${x+w-11},${y+1} ${x+w-1},${y+1} ${x+w-1},${y+h-9} ${x+w-11},${y+h-1}`,a);}
function scene(kind,sport,a){
  const base=ellipse(111,139,84,8,'shadow',.65);
  let back=base,main='',moving='',pivot=[110,80],motion={x:0,y:-3,rotate:0,scale:1};
  if(kind==='tactics'){
    back+=poly('23,103 119,67 204,105 108,149','turfDeep')+poly('23,98 119,62 204,100 108,143','turf','turfLight',1.5)+line('M71 116 162 80M40 100 119 70 188 100 108 133Z','pale',1,.45)+`<ellipse cx="113" cy="101" rx="19" ry="9" fill="none" stroke="${materials.pale}" opacity=".45"/>`;
    for(let i=0;i<3;i++){const k=i===1?1:.8; main+=group(tileCard(-21,-32,42,63,a)+group(portrait('football',a,i),'translate(-37 -35) scale(.33)')+line('M-13 22H5',a,2),`translate(${66+i*44} ${55-(i===1?11:0)}) rotate(${(i-1)*-10}) scale(${k})`);}
    main+=line('M57 106 101 118 140 99 170 108',a,1.7,.7)+[57,101,140,170].map((x,i)=>circle(x,[106,118,99,108][i],3,a)).join('');
    moving=circle(101,118,5,'pale',a,2);pivot=[101,118];motion={x:39,y:-19,rotate:0,scale:1};
  }else if(kind==='penalty'){
    back+=poly('24,113 178,90 207,130 52,148','turfDeep')+poly('24,108 178,85 207,125 52,142','turf')+line('M42 112 174 94 192 123','pale',1,.4);
    main+=poly('54,40 69,28 185,28 185,86 170,101 170,40','courtDeep')+line('M70 40V95M90 40V96M110 40V97M130 40V98M150 40V99M54 57H170M54 76H170','steel',.8,.35)+line('M56 100V40H171V101M69 28H185V86','pale',4)+line('M57 43H168V98','steel',1)+line('M86 123Q102 88 149 62',a,1.7,.6)+circle(149,62,9,'none',a,1.5)+circle(149,62,2,a);
    moving=ball('football',83,123,16);pivot=[83,123];motion={x:12,y:-10,rotate:12,scale:1};
  }else if(kind==='chess'){
    back+=poly('30,86 113,38 195,83 195,93 113,145 30,97','courtDeep');
    const point=(x,y)=>[113+(x-y)*16.3,39+(x+y)*9.3];
    for(let r=0;r<5;r++)for(let q=0;q<5;q++){const pts=[[q,r],[q+1,r],[q+1,r+1],[q,r+1]].map(([x,y])=>point(x,y).join(',')).join(' ');main+=poly(pts,(r+q)%2?'panel':'courtLight');}
    const piece=(x,y,col)=>ellipse(x,y+7,8,4,'shadow')+p(`M${x-7} ${y+6}l3-12h8l3 12Z`,col,'ink')+circle(x,y-9,5,col,'ink')+line(`M${x-4} ${y+3}H${x+4}`,'pale',1,.6);
    [[80,91],[112,111],[144,92],[128,65]].forEach(([x,y],i)=>main+=piece(x,y,i<2?a:'steel'));
    main+=line('M97 82 113 73 130 83',a,2);moving=piece(96,81,a);pivot=[96,81];motion={x:16,y:-9,rotate:0,scale:1};
  }else if(kind==='cricket'){
    back+=poly('26,112 154,56 196,113 69,152','turfDeep')+poly('26,107 154,51 196,108 69,147','turf')+poly('67,129 129,66 163,80 101,144','clayDeep')+poly('67,124 129,61 163,75 101,139','clay')+line('M71 123 105 136M121 73 153 86','pale',1.6,.7);
    [132,141,150].forEach(x=>main+=p(`M${x} 38h4v48h-4Z`,'clayLight','clayDeep',.8)+p(`M${x+2} 39h2v47h-2Z`,'clay'));
    main+=line('M131 38H153','clayLight',3)+bat(79,82,1.08)+line('M167 101Q167 70 177 53',a,1.4,.6);moving=ball('cricket',168,99,11);pivot=[168,99];motion={x:6,y:-13,rotate:25,scale:1};
  }else if(kind==='basketball'){
    back+=poly('24,111 127,69 205,109 102,153','woodDeep')+poly('24,106 127,64 205,104 102,146','wood')+poly('55,118 124,91 174,116 103,140','woodLight')+line('M44 106 126 73 188 105 104 137Z','pale',1.2,.55)+line('M91 122Q80 91 125 86Q151 88 159 113','pale',1,.55);
    main+=p('M162 51H168V112H162Z','steel')+p('M133 21H185V57H133Z','panel','steel',2)+p('M137 25H181V53H137Z','pale')+line('M149 37H169V49H149Z','orange',1.5)+ellipse(158,57,18,6,'orangeDeep')+`<ellipse cx="158" cy="55" rx="18" ry="5" fill="none" stroke="${materials.orange}" stroke-width="3"/>`+line('M143 59 148 75 165 75 173 59M150 60 154 75M163 60V75','steel',1,.8)+line('M74 113Q87 42 146 53',a,1.5,.6);
    moving=ball('basketball',75,110,20);pivot=[75,110];motion={x:7,y:-12,rotate:12,scale:1};
  }else if(kind==='racing'){
    back+=poly('29,115 166,39 195,61 59,144','slate')+poly('44,119 170,49 181,58 54,129','panel')+line('M39 114 165 44M62 137 188 67','steel',1.3,.55)+line('M67 120Q110 87 167 60',a,1.5,.65);
    let car=ellipse(112,107,42,12,'shadow');
    car+=group(p('M-38-13H-23V7H-38Z','rubber','slate',1.8)+p('M23-13H38V7H23Z','rubber','slate',1.8)+p('M-37 30H-21V50H-37Z','rubber','slate',1.8)+p('M21 30H37V50H21Z','rubber','slate',1.8)+line('M-28-7H28M-29 38H29','steel',2)+p('M-8-30H8L15 5 23 16 19 38 8 46H-8L-19 38-23 16-15 5Z',a,'ink',1.7)+p('M0-28H7L14 5 22 17 18 37 7 45H0Z','redDeep')+p('M-6-22H-2V-2H-7Z','pale')+p('M-9 6-7 20H7L9 6 4 1H-4Z','ink','steel',1.2)+p('M-23-30H23V-24H-23Z','steel','ink')+p('M-29 43H29V50H-29Z','panel','steel')+line('M-11 25-12 36M11 25 12 36','pale',1.5,.7),'translate(114 82) rotate(29) scale(.82)');
    moving=car;pivot=[114,82];motion={x:5,y:-4,rotate:0,scale:1};
  }else if(kind==='tennis'){
    // One affine court grid: every line and the raised net share its axes.
    const courtPoint=(u,v)=>[24+102*u+78*v,100-52*u+44*v];
    const pt=(u,v,lift=0)=>{const [x,y]=courtPoint(u,v);return x.toFixed(2)+','+(y-lift).toFixed(2);};
    const courtLine=(points)=>line('M'+points.map(([u,v])=>pt(u,v)).join('L'),'pale',1.2,.68);
    back+=poly('24,106 126,54 204,98 102,150','courtDeep')+poly('24,100 126,48 204,92 102,144','court','courtLight',1);
    back+=courtLine([[.1,.12],[.9,.12],[.9,.88],[.1,.88],[.1,.12]])
      +courtLine([[.1,.2],[.9,.2]])+courtLine([[.1,.8],[.9,.8]])
      +courtLine([[.3,.2],[.3,.8]])+courtLine([[.7,.2],[.7,.8]])
      +courtLine([[.3,.5],[.7,.5]]);
    const mesh=poly([pt(.5,.04,20),pt(.5,.96,20),pt(.5,.96,3),pt(.5,.04,3)].join(' '),'ink',undefined,1,.82);
    back+=mesh;
    for(let i=1;i<9;i++){const v=.04+.92*i/9;back+=line('M'+pt(.5,v,20)+'L'+pt(.5,v,3),'steel',.7,.75);}
    for(const lift of [8,14])back+=line('M'+pt(.5,.04,lift)+'L'+pt(.5,.96,lift),'steel',.7,.75);
    for(const v of [-.03,1.03]){const [x,y]=courtPoint(.5,v);back+=ellipse(x,y+1,4,2,'shadow')+p('M'+(x-1.5)+' '+(y-23)+'h3v23h-3Z','steel');}
    back+=line('M'+pt(.5,-.03,21)+'L'+pt(.5,1.03,21),'pale',2)+line('M'+pt(.5,.04,3)+'L'+pt(.5,.96,3),'steel',.8,.8);
    main+=racket(61,57,1.25,a)+line('M101 110Q134 56 174 65',a,1.4,.65);moving=ball('tennis',174,65,12);pivot=[174,65];motion={x:-8,y:6,rotate:10,scale:1};
  }else if(kind==='quiz'){
    back+=group(p(cut(55,21,108,104,10),'courtDeep','edge',1.5),'rotate(-9 110 80)');
    main+=p(cut(52,20,110,111,9),'panel',a,1.5)+p(cut(58,26,98,55,6),'shadow')+line('M65 93H95M65 116H88','steel',2,.6);
    // Geometric question mark, independent of fonts.
    main+=p('M83 44Q84 31 99 31Q114 31 114 43Q114 51 105 55L103 62H94L95 51Q105 48 105 43Q105 39 99 39Q93 39 93 44Z',a)+p('M94 66H103V74H94Z',a);
    main+=p(cut(64,86,39,16,3),'slate')+p(cut(111,86,39,16,3),'slate')+p(cut(64,109,39,16,3),'slate')+p(cut(111,109,39,16,3),'slate');
    const cue=sport==='cricket'?bat(171,92,.66):sport==='tennis'?racket(174,88,.79,a):sport==='motorsport'?helmet(177,97,.57,a):ball(sport,177,107,22);
    main+=cue;moving=p(cut(111,86,39,16,3),a)+line('M125 93 130 97 138 90','ink',2);pivot=[130,94];motion={x:0,y:0,rotate:0,scale:1.035};
  }else if(kind==='bingo'){
    main+=p(cut(46,20,128,118,10),'panel',a,1.5)+p('M51 35H167V39H51Z',a);
    for(let y=0;y<3;y++)for(let x=0;x<3;x++)main+=p(cut(56+x*37,47+y*28,31,23,3),(x===y)?a:'slate')+(x===y?line(`M${64+x*37} ${58+y*28}l4 4 8-9`,'ink',2):circle(72+x*37,58+y*28,3,'steel'));
    moving=line('M72 58 109 86 146 114','pale',2.3);pivot=[110,85];motion={x:0,y:0,rotate:0,scale:1.025};
  }else if(kind==='player'||kind==='driver'){
    back+=group(p(cut(54,19,111,119,9),'courtDeep','edge',1),'rotate(8 110 80)');
    main+=p(cut(45,16,124,125,10),'panel',a,1.6)+p(cut(51,23,112,109,6),'shadow');
    main+=kind==='driver'?helmet(112,69,1.3,a):portrait(sport,a);
    main+=p('M52 113H162V134H52Z','panel')+line('M61 120H106M61 127H92',a,2,.75)+line('M131 119H150M131 126H145','steel',1.5,.5);
    main+=kind==='driver'?line('M170 87 178 79 189 83 188 101 175 104Z',a,2):sport==='cricket'?bat(179,99,.58):ball(sport,180,115,17);
    moving=poly('53,101 162,88 162,94 53,107',a);pivot=[110,97];motion={x:0,y:-28,rotate:0,scale:1,opacity:.18};
  }else if(kind==='winner'){
    back+=racket(51,67,.9,'steel')+racket(173,65,.9,'steel');
    main+=p('M78 32H144V66L134 87 121 94V116H141V131H81V116H101V94L88 87 78 66Z','gold','clayDeep',1.7)+p('M111 33H144V66L134 87 121 94V116H141V131H111Z','clay')+p('M83 38H90V63L98 79 93 80 85 64Z','clayLight')+line('M78 40H64V58Q64 78 90 81M144 40H157V58Q157 78 133 81','gold',5)+p(cut(81,117,60,15,3),'panel',a,1.4)+line('M96 124H126',a,2)+ball('tennis',172,117,11);
    moving=p('M101 51 112 41 123 51 112 66Z','pale');pivot=[112,53];motion={x:0,y:-2,rotate:0,scale:1.03,opacity:.65};
  }
  return { layers:[{id:'setting',svg:back},{id:'subject',svg:main},{id:'action',svg:moving}],pivot,motion };
}
export function author(root){
  fs.mkdirSync(path.join(root,'masters'),{recursive:true});
  const manifest={version:1,width:220,height:160,cycleMs:4800,stillPhase:.28,materials,games:{}};
  for(const [id,flutter,sport,title,kind,accent] of catalog){
    const art=scene(kind,sport,accent);
    // One restrained action, settling and holding before a smooth return.
    const pose=(amount)=>({x:art.motion.x*amount,y:art.motion.y*amount,rotate:art.motion.rotate*amount,scale:1+(art.motion.scale-1)*amount,opacity:art.motion.opacity??1});
    const tracks=[{at:0,...pose(0)},{at:.12,...pose(0)},{at:.4,...pose(1)},{at:.68,...pose(1)},{at:.88,...pose(0)},{at:1,...pose(0)}];
    manifest.games[id]={flutter,sport,title,kind,accent,pivot:art.pivot,layers:art.layers.map(l=>({id:l.id,frames:l.id==='action'?tracks:[]}))};
    const svg=`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 220 160"><title>${title} — original StatOz artwork</title>\n${art.layers.map(l=>`<g data-layer="${l.id}">${l.svg}</g><!-- end-layer -->`).join('\n')}\n</svg>\n`;
    fs.writeFileSync(path.join(root,'masters',`${id}.svg`),svg);
  }
  fs.writeFileSync(path.join(root,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
}
if(process.argv[2])author(process.argv[2]);
