import fs from 'node:fs';
import zlib from 'node:zlib';

function zipEntries(buffer) {
  let eocd = -1;
  for (let i = buffer.length - 22; i >= Math.max(0, buffer.length - 65557); i -= 1) {
    if (buffer.readUInt32LE(i) === 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw new Error('Invalid XLSX/ZIP: end-of-central-directory not found.');
  const entries = new Map();
  const count = buffer.readUInt16LE(eocd + 10);
  let offset = buffer.readUInt32LE(eocd + 16);
  for (let i = 0; i < count; i += 1) {
    if (buffer.readUInt32LE(offset) !== 0x02014b50) throw new Error('Invalid ZIP central directory entry.');
    const method = buffer.readUInt16LE(offset + 10);
    const compressedSize = buffer.readUInt32LE(offset + 20);
    const nameLength = buffer.readUInt16LE(offset + 28);
    const extraLength = buffer.readUInt16LE(offset + 30);
    const commentLength = buffer.readUInt16LE(offset + 32);
    const localOffset = buffer.readUInt32LE(offset + 42);
    const name = buffer.subarray(offset + 46, offset + 46 + nameLength).toString('utf8');
    const localNameLength = buffer.readUInt16LE(localOffset + 26);
    const localExtraLength = buffer.readUInt16LE(localOffset + 28);
    const dataStart = localOffset + 30 + localNameLength + localExtraLength;
    const compressed = buffer.subarray(dataStart, dataStart + compressedSize);
    let data;
    if (method === 0) data = compressed;
    else if (method === 8) data = zlib.inflateRawSync(compressed);
    else throw new Error(`Unsupported ZIP compression method ${method} for ${name}`);
    entries.set(name.replaceAll('\\', '/'), data);
    offset += 46 + nameLength + extraLength + commentLength;
  }
  return entries;
}

function decodeXml(value) {
  return value
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&')
    .replace(/&#(\d+);/g, (_, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCodePoint(Number.parseInt(code, 16)));
}

function attribute(tag, name) {
  const match = tag.match(new RegExp(`(?:^|\\s)${name}="([^"]*)"`));
  return match ? decodeXml(match[1]) : null;
}

function columnIndex(reference) {
  const letters = reference.match(/^[A-Z]+/)?.[0] ?? '';
  let result = 0;
  for (const letter of letters) result = result * 26 + letter.charCodeAt(0) - 64;
  return result - 1;
}

function parseSharedStrings(xml) {
  if (!xml) return [];
  return [...xml.matchAll(/<si(?:\s[^>]*)?>([\s\S]*?)<\/si>/g)].map((match) => (
    [...match[1].matchAll(/<t(?:\s[^>]*)?>([\s\S]*?)<\/t>/g)].map((part) => decodeXml(part[1])).join('')
  ));
}

function parseWorksheet(xml, sharedStrings) {
  const rows = [];
  for (const rowMatch of xml.matchAll(/<row(?:\s[^>]*)?>([\s\S]*?)<\/row>/g)) {
    const row = [];
    for (const cellMatch of rowMatch[1].matchAll(/<c([^>]*)>([\s\S]*?)<\/c>/g)) {
      const tag = cellMatch[1];
      const body = cellMatch[2];
      const reference = attribute(tag, 'r');
      const type = attribute(tag, 't');
      const index = reference ? columnIndex(reference) : row.length;
      let value = null;
      const raw = body.match(/<v>([\s\S]*?)<\/v>/)?.[1];
      if (type === 's' && raw !== undefined) value = sharedStrings[Number(raw)] ?? null;
      else if (type === 'inlineStr') value = [...body.matchAll(/<t(?:\s[^>]*)?>([\s\S]*?)<\/t>/g)].map((part) => decodeXml(part[1])).join('');
      else if (raw !== undefined) value = Number.isFinite(Number(raw)) ? Number(raw) : decodeXml(raw);
      row[index] = value;
    }
    rows.push(row);
  }
  return rows;
}

export function readXlsx(file) {
  const entries = zipEntries(fs.readFileSync(file));
  const workbook = entries.get('xl/workbook.xml')?.toString('utf8');
  const relationships = entries.get('xl/_rels/workbook.xml.rels')?.toString('utf8');
  if (!workbook || !relationships) throw new Error('Invalid XLSX: workbook metadata is missing.');
  const rels = new Map([...relationships.matchAll(/<Relationship\s+([^>]+?)\/?>(?:<\/Relationship>)?/g)].map((match) => [attribute(match[1], 'Id'), attribute(match[1], 'Target')]));
  const shared = parseSharedStrings(entries.get('xl/sharedStrings.xml')?.toString('utf8'));
  const output = new Map();
  for (const match of workbook.matchAll(/<sheet\s+([^>]+?)\/?>(?:<\/sheet>)?/g)) {
    const name = attribute(match[1], 'name');
    const relationId = attribute(match[1], 'r:id');
    let target = rels.get(relationId);
    if (!name || !target) continue;
    target = target.replace(/^\//, '').replace(/^xl\//, '');
    const entry = entries.get(`xl/${target}`)?.toString('utf8');
    if (entry) output.set(name, parseWorksheet(entry, shared));
  }
  return output;
}

export function excelSerialToIso(serial) {
  if (!Number.isFinite(Number(serial))) return null;
  const milliseconds = Math.round((Number(serial) - 25569) * 86400000);
  return new Date(milliseconds).toISOString().slice(0, 10);
}
