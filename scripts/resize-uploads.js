#!/usr/bin/env node
const chokidar = require('chokidar')
const sharp = require('sharp')
const path = require('path')
const fs = require('fs')

const DIR = path.resolve(process.cwd(), 'static', 'img')
const sizes = [1920, 1200, 800]
const validExt = new Set(['.jpg', '.jpeg', '.png', '.webp'])

function isGenerated(name) {
  return /-\d+w(\.|$)/.test(name)
}

async function generateSizes(file) {
  try {
    const ext = path.extname(file).toLowerCase()
    if (!validExt.has(ext)) return
    const dir = path.dirname(file)
    const base = path.basename(file, ext)
    if (isGenerated(base)) return

    // ensure file exists and is stable (size stops changing)
    let prev = -1
    for (let i = 0; i < 5; i++) {
      const { size } = fs.statSync(file)
      if (size === prev) break
      prev = size
      await new Promise((r) => setTimeout(r, 200))
    }

    for (const w of sizes) {
      const out = path.join(dir, `${base}-${w}w${ext}`)
      if (fs.existsSync(out)) continue
      await sharp(file).resize({ width: w }).toFile(out)
      console.log(new Date().toISOString(), 'generated', out)
    }
  } catch (err) {
    console.error('resize error for', file, err)
  }
}

async function processExisting() {
  if (!fs.existsSync(DIR)) return
  const files = fs.readdirSync(DIR)
  for (const f of files) {
    const p = path.join(DIR, f)
    const stat = fs.statSync(p)
    if (!stat.isFile()) continue
    await generateSizes(p)
  }
}

async function main() {
  const once = process.argv.includes('--once')
  if (once) {
    await processExisting()
    console.log('done')
    process.exit(0)
  }

  if (!fs.existsSync(DIR)) {
    console.warn('dir not found:', DIR)
    fs.mkdirSync(DIR, { recursive: true })
  }

  const watcher = chokidar.watch(DIR, { ignoreInitial: true })
  watcher.on('add', (file) => {
    setTimeout(() => generateSizes(file), 500)
  })
  watcher.on('change', (file) => {
    setTimeout(() => generateSizes(file), 500)
  })

  console.log('Watching', DIR, 'for uploads...')
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
