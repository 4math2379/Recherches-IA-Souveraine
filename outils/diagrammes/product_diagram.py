"""Architecture diagrams for the sovereign AI products, with official Scaleway icons.

usage: product_diagram.py icons.json <product> <static|vars> out.svg
"""
import json, re, sys

icons = json.load(open(sys.argv[1]))
product, mode, out = sys.argv[2], sys.argv[3], sys.argv[4]

if mode == 'vars':
    C = dict(fg='var(--fg)', muted='var(--muted)', line='var(--line)', surface='var(--surface)', accent='var(--accent)',
             tint='var(--tint-neutral)', sl='var(--serverless)', tsl='var(--tint-serverless)', gpu='var(--gpu)',
             tgpu='var(--tint-gpu)', data='var(--data)', tdata='var(--tint-data)', bg='var(--bg)',
             body='var(--font-body)', mono='var(--font-mono)')
else:
    C = dict(fg='#141922', muted='#5A6475', line='#C9D0DB', surface='#FFFFFF', accent='#2B55C9', tint='#EEF1F5',
             sl='#0F7F63', tsl='#E3F3EE', gpu='#A86A12', tgpu='#F7EEDF', data='#5B4FB8', tdata='#ECEAF8', bg='#F5F7FA',
             body='Public Sans, Segoe UI, system-ui, sans-serif', mono='JetBrains Mono, ui-monospace, Menlo, monospace')

def esc(t):
    return t.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

def icon(name, x, y, s=36):
    inner = re.sub(r'^<svg[^>]*>|</svg>$', '', icons[name])
    return f'<svg x="{x}" y="{y}" width="{s}" height="{s}" viewBox="0 0 64 64" aria-hidden="true">{inner}</svg>'

def node(x, y, w, h, ic, title, lines, tag=None, stroke=None, fill=None, dash=False, sw=1.4):
    stroke = stroke or C['fg']; fill = fill or C['surface']
    d = ' stroke-dasharray="6 4"' if dash else ''
    s = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>'
    tx = x + 14
    if ic:
        s += icon(ic, x + 12, y + 12)
        tx = x + 58
    s += f'<text x="{tx}" y="{y+28}" class="t">{esc(title)}</text>'
    if tag:
        s += f'<text x="{tx}" y="{y+45}" class="m">{esc(tag)}</text>'
    for i, l in enumerate(lines):
        s += f'<text x="{x+14}" y="{y+70+i*18}" class="s">{esc(l)}</text>'
    return s

def arrow(d, label=None, lx=0, ly=0, cls='f', marker='a'):
    s = f'<path class="{cls}" d="{d}" marker-end="url(#{marker})"/>'
    if label:
        s += f'<text x="{lx}" y="{ly}" class="m">{esc(label)}</text>'
    return s

SPEC = {
    'rag': dict(
        title='RAG souverain',
        app=('Instance', 'Open WebUI', 'PLAY2-MICRO', ['ingestion des documents', 'recherche + chat cité', 'comptes et groupes']),
        genai=['Mistral Small 3.2', 'bge-multilingual-gemma2'],
        data=[('PostgresqlMysql', 'PostgreSQL', 'PGVECTOR · DB-DEV-M', ['halfvec HNSW, 3 584 dim', 'comptes, conversations'])],
        storage=('ObjectStorage', 'Object Storage', 'DOCUMENTS · VERSIONNÉ', ['fichiers déposés']),
        extra=None,
    ),
    'agents': dict(
        title='Agents souverains',
        app=('Instance', 'Langflow', 'PLAY2-MICRO', ['agents et flows visuels', 'chaque flow = une API', 'outil MCP Scaleway (option)']),
        genai=['Mistral Small 3.2, Medium 3.5', 'Devstral 2 (code)'],
        data=[('PostgresqlMysql', 'PostgreSQL', 'DB-DEV-M', ['flows, historique, variables'])],
        storage=None,
        extra=('outils externes via NAT', 'MCP Scaleway lecture seule'),
    ),
    'analytics': dict(
        title='Analyse souveraine',
        app=('Instance', 'Hôte BI', 'PLAY2-MICRO', ['Superset (bi.<domaine>)', 'chat analyste Open WebUI', 'serveur MCP ClickHouse']),
        genai=['Mistral Small 3.2, Medium 3.5', 'bge-multilingual-gemma2'],
        data=[('DataWarehouse', 'Data Warehouse', 'CLICKHOUSE V26', ['2 à 4 vCPU, autoscaling', 'base analytics']),
              ('PostgresqlMysql', 'PostgreSQL', 'DB-DEV-M', ['métadonnées Superset', 'et Open WebUI'])],
        storage=('ObjectStorage', 'Object Storage', 'LANDING CSV · PARQUET', ['chargé par s3()']),
        extra=None,
    ),
}
S = SPEC[product]

W, H = 1180, 830
p = [f'''<svg viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg" role="img" font-family="{C['body']}">
<defs>
<marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="{C['accent']}"/></marker>
<marker id="d" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="{C['data']}"/></marker>
<marker id="g" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="{C['muted']}"/></marker>
</defs>
<style>
.t{{font-family:{C['body']};font-size:14px;font-weight:600;fill:{C['fg']}}}
.s{{font-family:{C['body']};font-size:12px;fill:{C['muted']}}}
.m{{font-family:{C['mono']};font-size:10.5px;fill:{C['muted']};letter-spacing:.04em}}
.f{{fill:none;stroke:{C['accent']};stroke-width:1.8}}
.dd{{fill:none;stroke:{C['data']};stroke-width:1.6;stroke-dasharray:6 4}}
.o{{fill:none;stroke:{C['muted']};stroke-width:1.4;stroke-dasharray:5 4}}
</style>''']
if mode == 'static':
    p.append(f'<rect width="{W}" height="{H}" fill="{C["bg"]}"/>')

# Region and VPC
p.append(f'<rect x="196" y="16" width="968" height="680" rx="14" fill="none" stroke="{C["line"]}" stroke-width="1.5" stroke-dasharray="3 5"/>')
p.append(f'<text x="212" y="40" class="m">RÉGION FR-PAR (PARIS) · ZONE FR-PAR-2 · {esc(S["title"].upper())}</text>')
p.append(f'<rect x="420" y="170" width="436" height="390" rx="12" fill="{C["tint"]}" fill-opacity=".6" stroke="{C["line"]}" stroke-width="1.5"/>')
p.append(icon('Vpc', 432, 180, 26))
p.append('<text x="466" y="198" class="m">VPC · PRIVATE NETWORK · DNS .internal</text>')
p.append('<text x="436" y="548" class="m">AUCUNE IP PUBLIQUE · ENDPOINTS PRIVÉS SEULEMENT</text>')

# Users and Public Gateway
p.append(node(16, 300, 162, 150, None, 'Utilisateurs', ['navigateur', 'apps (SDK OpenAI)', 'admin via bastion'], tag='HTTPS'))
p.append(node(214, 300, 184, 150, 'PublicGateway', 'Public Gateway', ['PAT 443 et 80', 'NAT sortant', 'bastion SSH :61000'], tag='SEULE IP PUBLIQUE'))

# Platform gateway and product app
p.append(node(440, 212, 190, 120, 'Instance', 'Passerelle IA', ['Caddy (TLS, sous-domaines)', 'LiteLLM : clés, alias, repli'], tag='SOCLE COMMUN', stroke=C['accent'], sw=2))
ic, t, tag, lines = S['app']
p.append(node(440, 360, 190, 150, ic, t, lines, tag=tag, stroke=C['fg'], sw=2))

# Data nodes inside the VPC
for i, (dic, dt, dtag, dl) in enumerate(S['data']):
    y = 212 + i * 160
    p.append(node(652, 212 + i * 160, 192, 130, dic, dt, dl, tag=dtag, stroke=C['data'], fill=C['tdata']))
    p.append(arrow(f'M630 {420 + i*30} H641 V{277 + i*160} H650', cls='dd', marker='d'))

# Generative APIs
p.append(node(652, 52, 192, 104, 'GenerativeApi', 'Generative APIs', S['genai'], tag='SERVERLESS', stroke=C['sl'], fill=C['tsl']))

# Object storage below the VPC
if S['storage']:
    sic, st, stag, sl = S['storage']
    p.append(node(440, 580, 190, 100, sic, st, sl, tag=stag, stroke=C['data'], fill=C['tdata']))
    p.append(arrow('M535 510 V578', cls='dd', marker='d'))
    if product == 'analytics':
        p.append(arrow('M630 640 H864 V277 H846', 'S3()', 790, 632, cls='dd', marker='d'))

# Extra (agents): outbound tools
if S['extra']:
    a, b = S['extra']
    p.append(node(652, 580, 192, 100, 'Containers', 'Outils des agents', [a, b], tag='OPTIONNEL', stroke=C['muted'], dash=True))
    p.append(arrow('M630 470 H641 V630 H650', cls='o', marker='g'))

# Security and operations column
col_x, y0 = 876, 52
p.append(f'<rect x="{col_x}" y="{y0}" width="272" height="628" rx="10" fill="{C["surface"]}" stroke="{C["line"]}" stroke-width="1.4"/>')
p.append(f'<text x="{col_x+16}" y="{y0+26}" class="m">SÉCURITÉ · EXPLOITATION</text>')
items = [('Iam', 'IAM', 'une application par usage'),
         ('SecretManager', 'Secret Manager', 'mots de passe et clés'),
         ('ObjectStorage', 'Object Storage', 'state Terraform versionné'),
         ('Registry', 'Container Registry', 'miroir des images'),
         ('Cockpit', 'Cockpit', 'métriques et logs'),
         ('AuditTrail', 'Audit Trail', 'qui a fait quoi'),
         ('SecurityGroup', 'Security Group', 'entrant fermé par défaut')]
for i, (ic2, t2, s2) in enumerate(items):
    yy = y0 + 48 + i * 82
    p.append(icon(ic2, col_x + 16, yy, 40))
    p.append(f'<text x="{col_x+68}" y="{yy+17}" class="t">{t2}</text><text x="{col_x+68}" y="{yy+35}" class="s">{s2}</text>')

# CI/CD band
p.append(f'<rect x="196" y="716" width="968" height="96" rx="10" fill="{C["surface"]}" stroke="{C["line"]}" stroke-width="1.4"/>')
p.append(icon('Terraform', 212, 740, 44))
p.append(f'<text x="268" y="756" class="t">GitHub Actions → Terraform · products/{product}</text>')
p.append('<text x="268" y="776" class="s">modules partagés platform, postgres, app-host · plan sur PR · apply manuel approuvé · state par produit</text>')
p.append('<text x="268" y="796" class="m">MÊME SOCLE POUR LES TROIS PRODUITS : SEULE LA COUCHE APPLICATIVE CHANGE</text>')

# Request flows
p.append(arrow('M178 375 H212', '443', 181, 366))
p.append(arrow('M398 375 H420 V272 H438', 'PAT', 403, 366))
p.append(arrow('M535 332 V358', None))
p.append(f'<text x="543" y="350" class="m">{"/ ET bi." if product == "analytics" else "/"}</text>')
p.append(arrow('M470 358 V334', None))
p.append('<text x="478" y="350" class="m">:4000</text>')
p.append(arrow('M540 212 V104 H650', 'HTTPS · CLÉ IAM', 548, 96))
p.append(f'<path class="o" d="M306 450 V610 H420"/><text x="312" y="600" class="m">SORTIE NAT</text>')
p.append(arrow('M640 716 V700', cls='o', marker='g'))
p.append('</svg>')
open(out, 'w').write('\n'.join(p))
print(out)
