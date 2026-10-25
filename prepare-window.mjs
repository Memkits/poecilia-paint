import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync,readdirSync,statSync,copyFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
assert.equal(process.env.GITHUB_ACTIONS,'true');assert.equal(process.platform,'linux');
const run=(exe,args)=>execFileSync(exe,args,{encoding:'utf8',maxBuffer:32e6,stdio:['pipe','pipe','pipe']});assert.equal(run('calcit',['-v']).trim(),'0.30.1');
const norm=v=>Array.isArray(v)?v.map(norm):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).map(([k,x])=>[k,k==='__edn_set'?x.map(norm).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b))):k==='schema'&&Array.isArray(x)&&x[0]==='{}'?['{}',...x.slice(1).map(norm).sort((a,b)=>a[0].localeCompare(b[0]))]:norm(x)])):v;
const q=(...args)=>{const r=JSON.parse(run('calcit',['query',...args,'--format','json']));assert.ok(!r.diagnostics?.some(d=>d.severity==='error'));return norm(r.data);};
const p=JSON.parse(readFileSync('reviewed-source.json')),m=JSON.parse(readFileSync('reviewed-migration.json')),mode=process.argv[2];mkdirSync('acceptance',{recursive:true});
function views(){const namespaces=[],defs=[];for(const ns of q('ns').namespaces){const info=q('ns',ns);namespaces.push(info);const names=run('calcit',['query','defs',ns]).split('\n').filter(l=>/^  \S/.test(l)).map(l=>l.trim().split(' ')[0]);assert.equal(names.length,info.definition_count);for(const n of names)defs.push(q('def',ns+'/'+n));}return {config:q('config'),namespaces,defs};}
const blob=()=>run('git',['hash-object','calcit.cirru']).trim();
if(mode==='apply'){
 assert.equal(blob(),p.blob);assert.deepEqual(views(),norm(p.before));assert.equal(readFileSync('deps.cirru','utf8'),m.beforeDeps);
 for(const [i,s]of p.sites.entries())writeFileSync('acceptance/before-subtree-'+i+'.json',run('calcit',['tree','show',s.id,'--path','@'+s.path.join('.'),'--format','json']));
 writeFileSync('acceptance/operations.json',JSON.stringify(m.operations));const args=['edit','transaction','--file','acceptance/operations.json','--format','json'];const preview=JSON.parse(run('calcit',[...args,'--dry-run']));assert.ok(preview.scoped_revision);assert.equal(blob(),p.blob);writeFileSync('acceptance/preview.json',JSON.stringify(preview));writeFileSync('acceptance/applied.json',run('calcit',[...args,'--expect-revision',preview.scoped_revision]));writeFileSync('acceptance/modified-blob.txt',blob());writeFileSync('deps.cirru',m.afterDeps);
 for(const [i,s]of p.sites.entries())writeFileSync('acceptance/after-subtree-'+i+'.json',run('calcit',['tree','show',s.id,'--path','@'+s.path.join('.'),'--format','json']));
}else if(mode==='before'||mode==='after'){
 const wanted=mode==='before'?p.before:m.expected;assert.deepEqual(views(),norm(wanted));assert.equal(blob(),mode==='before'?p.blob:readFileSync('acceptance/modified-blob.txt','utf8'));
 for(const [f,h]of Object.entries(p.ordinaryBlobs)){if(f==='deps.cirru')assert.equal(readFileSync(f,'utf8'),mode==='before'?m.beforeDeps:m.afterDeps);else assert.equal(run('git',['hash-object',f]).trim(),h,f);}
 writeFileSync('acceptance/'+mode+'-source.json',JSON.stringify(views()));
 const raw=run('calcit',['--check-only',...wanted.namespaces.flatMap(n=>['--ns',n.namespace]),'--format','json']);writeFileSync('acceptance/'+mode+'-namespaces.json',raw);const report=JSON.parse(raw);assert.deepEqual([...report.data.checked_definition_ids].sort(),wanted.defs.map(d=>d.id).sort());assert.ok(!report.diagnostics.some(d=>d.severity==='error'));for(const d of wanted.defs)assert.equal(report.data.definitions.find(r=>r.id===d.id)?.status,'passed',d.id);
}else if(mode==='before-js'||mode==='after-js'){
 const files=[];function visit(dir){for(const n of readdirSync(dir).sort()){const f=dir+'/'+n;if(statSync(f).isDirectory())visit(f);else if(f.endsWith('.mjs'))files.push({path:f,sha256:createHash('sha256').update(readFileSync(f)).digest('hex')});}}visit('js-out');writeFileSync('acceptance/'+mode+'.json',JSON.stringify(files));
 if(mode==='before-js')for(const f of files){const dest='/tmp/poecilia-before/'+f.path;mkdirSync(dest.slice(0,dest.lastIndexOf('/')),{recursive:true});copyFileSync(f.path,dest);}
 else{const before=JSON.parse(readFileSync('acceptance/before-js.json')),a=new Map(files.map(f=>[f.path,f.sha256])),b=new Map(before.map(f=>[f.path,f.sha256])),changed=[...new Set([...a.keys(),...b.keys()])].filter(f=>a.get(f)!==b.get(f));let diff='';for(const f of changed){try{run('diff',['-u','--label','before/'+f,'--label','after/'+f,b.has(f)?'/tmp/poecilia-before/'+f:'/dev/null',a.has(f)?f:'/dev/null']);}catch(e){assert.equal(e.status,1);diff+=e.stdout;}}writeFileSync('acceptance/generated-js.diff',diff);writeFileSync('acceptance/generated-js-evidence.json',JSON.stringify({before:before.length,after:files.length,changed}));}
}else throw Error('invalid mode');
