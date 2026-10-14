// Convert @ultraviolet/icons generated ProductIcon modules to plain SVG strings.
import fs from 'node:fs';
const [dir, out, ...names] = process.argv.slice(2);
const attr = (k) => ({ className: 'class', fillRule: 'fill-rule', clipRule: 'clip-rule', clipPath: 'clip-path', strokeWidth: 'stroke-width', stopColor: 'stop-color', stopOpacity: 'stop-opacity', fillOpacity: 'fill-opacity' }[k] || k);
const ser = (n) => {
  if (n == null || n === false) return '';
  if (Array.isArray(n)) return n.map(ser).join('');
  if (typeof n !== 'object') return String(n);
  const { children, ...rest } = n.props || {};
  if (n.type === 'ICON') return ser(children);
  const a = Object.entries(rest).filter(([k]) => k !== 'className').map(([k, v]) => ` ${attr(k)}="${v}"`).join('');
  return `<${n.type}${a}>${ser(children)}</${n.type}>`;
};
const res = {};
for (const name of names) {
  let src = fs.readFileSync(`${dir}/${name}ProductIcon.js`, 'utf8');
  src = src.replace(/^import .*$/gm, '').replace(/^export .*$/gm, '').replace(/^'use client';/m, '');
  const fn = new Function('jsx', 'jsxs', 'Icon', '__esmMin', '__name', '_objectSpread2', 'init_Icon', 'init_objectSpread2',
    src + `\n; init_${name}ProductIcon(); return ${name}ProductIcon;`);
  const C = fn((t, p) => ({ type: t, props: p }), (t, p) => ({ type: t, props: p }), 'ICON',
    (f) => () => f(), (x) => x, (...o) => Object.assign({}, ...o), () => {}, () => {});
  const tree = C({});
  res[name] = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">${ser(tree.type === 'ICON' ? tree.props.children : tree)}</svg>`;
}
fs.writeFileSync(out, JSON.stringify(res, null, 1));
console.log(Object.keys(res).map(k => `${k}:${res[k].length}`).join(' '));
