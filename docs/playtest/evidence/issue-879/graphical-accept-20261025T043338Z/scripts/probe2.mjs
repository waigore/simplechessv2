import { spawn } from 'node:child_process';
import fs from 'node:fs'; import os from 'node:os'; import path from 'node:path';
const CHROME = process.env.CHROME_BIN; const port = 9912;
const sleep = (ms) => new Promise(r=>setTimeout(r,ms));
const profile = fs.mkdtempSync(path.join(os.tmpdir(),'p2-'));
const chrome = spawn(CHROME, ['--headless=new',`--remote-debugging-port=${port}`,`--user-data-dir=${profile}`,'--no-first-run','--hide-scrollbars','--window-size=390,844','--force-device-scale-factor=3','--use-angle=swiftshader','--enable-unsafe-swiftshader','--no-sandbox','about:blank'],{stdio:['ignore','pipe','pipe']});
chrome.stderr.resume();
async function target(){ for(let i=0;i<200;i++){ await sleep(100); try{ const l=await (await fetch(`http://127.0.0.1:${port}/json/list`)).json(); const p=l.find(t=>t.type==='page'); if(p) return p; }catch{} } throw new Error('no target'); }
async function attach(){ const t=await target(); const ws=new WebSocket(t.webSocketDebuggerUrl); await new Promise((res,rej)=>{ws.onopen=res;ws.onerror=rej;}); let n=0; const pend=new Map();
 ws.onmessage=(m)=>{ const d=JSON.parse(m.data); if(d.id&&pend.has(d.id)){const {res,rej}=pend.get(d.id);pend.delete(d.id); d.error?rej(new Error(JSON.stringify(d.error))):res(d.result);} };
 const call=(method,params={})=>new Promise((res,rej)=>{const id=++n;pend.set(id,{res,rej});ws.send(JSON.stringify({id,method,params}));});
 return {call,ws,targetId:t.id}; }
let s = await attach();
console.log('attach1 target', s.targetId);
await s.call('Page.enable'); await s.call('Runtime.enable');
await s.call('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:3,mobile:true});
await s.call('Emulation.setTouchEmulationEnabled',{enabled:true,maxTouchPoints:5});
await s.call('Page.navigate',{url:'https://waigore.github.io/simplechessv2/'});
for (let i=0;i<10;i++){ await sleep(3000);
  try { await s.call('Runtime.evaluate',{expression:'document.readyState',returnByValue:true}); console.log(i,'same-session evaluate OK', (await target()).id===s.targetId); }
  catch(e){ console.log(i,'same-session FAILED:',e.message); s = await attach(); console.log('  reattached to', s.targetId); }
}
chrome.kill('SIGKILL');
