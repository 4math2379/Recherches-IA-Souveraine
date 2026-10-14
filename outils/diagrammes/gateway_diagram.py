import json, re, sys
icons = json.load(open(sys.argv[1]))
mode = sys.argv[2]  # 'vars' (artifact, themed) or 'static' (repo file)
out = sys.argv[3]

if mode == 'vars':
    C = dict(fg='var(--fg)', muted='var(--muted)', line='var(--line)', surface='var(--surface)', accent='var(--accent)',
             tint='var(--tint-neutral)', sl='var(--serverless)', tsl='var(--tint-serverless)', gpu='var(--gpu)', tgpu='var(--tint-gpu)',
             data='var(--data)', bg='var(--bg)', body='var(--font-body)', mono='var(--font-mono)')
else:
    C = dict(fg='#141922', muted='#5A6475', line='#C9D0DB', surface='#FFFFFF', accent='#2B55C9', tint='#EEF1F5',
             sl='#0F7F63', tsl='#E3F3EE', gpu='#A86A12', tgpu='#F7EEDF', data='#5B4FB8', bg='#F5F7FA',
             body='Public Sans, Segoe UI, system-ui, sans-serif', mono='JetBrains Mono, ui-monospace, Menlo, monospace')

def icon(name, x, y, s=36):
    svg = icons[name]
    inner = re.sub(r'^<svg[^>]*>|</svg>$', '', svg)
    return f'<svg x="{x}" y="{y}" width="{s}" height="{s}" viewBox="0 0 64 64" aria-hidden="true">{inner}</svg>'

def node(x, y, w, h, ic, title, lines, tag=None, stroke=None, fill=None, dash=False, sw=1.4):
    stroke = stroke or C['fg']; fill = fill or C['surface']
    d = ' stroke-dasharray="6 4"' if dash else ''
    s = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>'
    tx = x + 14
    if ic:
        s += icon(ic, x + 12, y + 12)
        tx = x + 58
    s += f'<text x="{tx}" y="{y+28}" class="t">{title}</text>'
    if tag: s += f'<text x="{tx}" y="{y+45}" class="m">{tag}</text>'
    for i, l in enumerate(lines):
        s += f'<text x="{x+14}" y="{y+70+i*18}" class="s">{l}</text>'
    return s

W, H = 1180, 790
p = []
p.append(f'''<svg viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg" role="img" font-family="{C['body']}">
<defs>
<marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="{C['accent']}"/></marker>
<marker id="g" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="{C['muted']}"/></marker>
</defs>
<style>
.t{{font-family:{C['body']};font-size:14px;font-weight:600;fill:{C['fg']}}}
.s{{font-family:{C['body']};font-size:12px;fill:{C['muted']}}}
.m{{font-family:{C['mono']};font-size:10.5px;fill:{C['muted']};letter-spacing:.04em}}
.f{{fill:none;stroke:{C['accent']};stroke-width:1.8}}
.o{{fill:none;stroke:{C['muted']};stroke-width:1.4;stroke-dasharray:5 4}}
</style>''')
if mode == 'static':
    p.append(f'<rect width="{W}" height="{H}" fill="{C["bg"]}"/>')

# Region frame
p.append(f'<rect x="196" y="16" width="968" height="640" rx="14" fill="none" stroke="{C["line"]}" stroke-width="1.5" stroke-dasharray="3 5"/>')
p.append('<text x="212" y="40" class="m">RÉGION FR-PAR (PARIS) · ZONE FR-PAR-2</text>')

# VPC / private network
p.append(f'<rect x="420" y="170" width="430" height="466" rx="12" fill="{C["tint"]}" fill-opacity=".6" stroke="{C["line"]}" stroke-width="1.5"/>')
p.append(icon('Vpc', 432, 180, 26))
p.append(f'<text x="466" y="198" class="m">VPC · PRIVATE NETWORK 172.16.32.0/22</text>')
p.append(f'<text x="436" y="622" class="m">AUCUNE IP PUBLIQUE SUR LES INSTANCES</text>')

# Applications
p.append(node(16, 300, 162, 150, None, 'Applications', ['RPG Map Gen (FastAPI)', 'Agents, IDE, chatbots', 'Scripts, back-office'], tag='SDK OPENAI'))
p.append(f'<text x="16" y="486" class="m">ADMIN SSH</text><text x="16" y="502" class="s">via bastion :61000</text>')

# Public Gateway
p.append(node(214, 300, 184, 150, 'PublicGateway', 'Public Gateway', ['PAT 443 et 80 → passerelle', 'NAT sortant', 'Bastion SSH :61000'], tag='SEULE IP PUBLIQUE'))

# AI gateway instance
p.append(node(440, 300, 184, 150, 'Instance', 'Passerelle IA', ['LiteLLM + Caddy (TLS)', 'alias mistral-chat', 'clés, fallback, logs'], tag='PLAY2-NANO', stroke=C['accent'], sw=2))

# Backends (one active, chosen by inference_mode)
p.append(node(650, 218, 200, 132, 'InstanceGpu', 'GPU Instance', ['vLLM · Mistral Small 3.2', 'FP8, 32k de contexte'], tag='L40S-1-48G', stroke=C['gpu'], fill=C['tgpu'], dash=True))
p.append(node(650, 372, 200, 132, 'Inference', 'Managed Inference', ['Mistral Small 3.2 FP8', 'endpoint privé'], tag='NŒUD L40S', stroke=C['gpu'], fill=C['tgpu'], dash=True))
p.append(f'<text x="652" y="530" class="m">OPTIONS GPU (inference_mode)</text>')

# Generative APIs (outside VPC, inside region)
p.append(node(650, 52, 200, 104, 'GenerativeApi', 'Generative APIs', ['Mistral Small 3.2', 'embeddings qwen3'], tag='SERVERLESS · DÉFAUT', stroke=C['sl'], fill=C['tsl']))

# Security & ops column
col_x, y0 = 876, 52
p.append(f'<rect x="{col_x}" y="{y0}" width="272" height="584" rx="10" fill="{C["surface"]}" stroke="{C["line"]}" stroke-width="1.4"/>')
p.append(f'<text x="{col_x+16}" y="{y0+26}" class="m">SÉCURITÉ · EXPLOITATION</text>')
items = [('Iam', 'IAM', 'appli dédiée, droit GenAI seul'),
         ('SecretManager', 'Secret Manager', 'clé maître de la passerelle'),
         ('ObjectStorage', 'Object Storage', 'state Terraform versionné'),
         ('Registry', 'Container Registry', 'miroir des images'),
         ('Cockpit', 'Cockpit', 'métriques et logs'),
         ('AuditTrail', 'Audit Trail', 'qui a fait quoi'),
         ('SecurityGroup', 'Security Group', 'entrant fermé par défaut')]
for i, (ic, t, s) in enumerate(items):
    yy = y0 + 46 + i * 76
    p.append(icon(ic, col_x + 16, yy, 40))
    p.append(f'<text x="{col_x+68}" y="{yy+17}" class="t">{t}</text><text x="{col_x+68}" y="{yy+35}" class="s">{s}</text>')

# CI/CD band
p.append(f'<rect x="196" y="680" width="968" height="92" rx="10" fill="{C["surface"]}" stroke="{C["line"]}" stroke-width="1.4"/>')
p.append(icon('Terraform', 212, 702, 44))
p.append('<text x="268" y="720" class="t">GitHub Actions → Terraform (provider scaleway ~&gt; 2.85)</text>')
p.append('<text x="268" y="740" class="s">plan sur chaque PR · apply manuel avec approbation · state chiffré dans Object Storage fr-par</text>')
p.append('<text x="268" y="758" class="m">MODIFIER inference_mode SUFFIT À BASCULER DE BACKEND, SANS TOUCHER AUX APPLICATIONS</text>')

# Flows
p.append(f'<path class="f" d="M178 375 H212" marker-end="url(#a)"/>')
p.append(f'<text x="181" y="366" class="m">443</text>')
p.append(f'<path class="f" d="M398 375 H438" marker-end="url(#a)"/>')
p.append(f'<text x="403" y="366" class="m">PAT</text>')
p.append(f'<path class="f" d="M624 330 H636 V284 H648" marker-end="url(#a)"/>')
p.append(f'<path class="f" d="M624 420 H636 V438 H648" marker-end="url(#a)"/>')
p.append(f'<path class="f" d="M532 300 V104 H648" marker-end="url(#a)"/>')
p.append(f'<text x="540" y="96" class="m">HTTPS · CLÉ IAM</text>')
# Egress via NAT (dotted)
p.append(f'<path class="o" d="M306 450 V560 H440"/>')
p.append(f'<text x="312" y="552" class="m">SORTIE NAT</text>')
# Terraform manages everything
p.append(f'<path class="o" d="M640 680 V650" marker-end="url(#g)"/>')
p.append('</svg>')
open(out, 'w').write('\n'.join(p))
print(out, sum(len(x) for x in p))
